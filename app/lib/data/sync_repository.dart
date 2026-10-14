import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:uuid/uuid.dart';
import 'local/local_store.dart';
import 'models/customer.dart';
import 'models/site.dart';
import 'models/field_note.dart';
import 'remote/api_service.dart';

const _uuid = Uuid();

/// Offline-first repository:
/// - all CRUD writes go to Hive immediately (dirty = true)
/// - sync() pushes dirty changes in dependency order (customers -> sites -> notes),
///   then pulls server state (which also restores data after reinstall)
class SyncRepository {
  final LocalStore local;
  final ApiService api;

  SyncRepository(this.local, this.api);

  Future<bool> get online async {
    final c = await Connectivity().checkConnectivity();
    return c.contains(ConnectivityResult.mobile) ||
        c.contains(ConnectivityResult.wifi) ||
        c.contains(ConnectivityResult.ethernet);
  }

  // ---------- local CRUD (works offline) ----------
  Future<Customer> saveCustomer({String? localId, required String name, required String contactInfo}) async {
    final Customer c;
    if (localId == null) {
      c = Customer(localId: _uuid.v4(), name: name, contactInfo: contactInfo);
    } else {
      final old = local.getCustomers().firstWhere((e) => e.localId == localId);
      c = old.copyWith(name: name, contactInfo: contactInfo, updatedAt: DateTime.now(), dirty: true);
    }
    await local.putCustomer(c);
    return c;
  }

  Future<void> deleteCustomer(String localId) async {
    Customer? found;
    for (final e in local.getCustomers()) {
      if (e.localId == localId) found = e;
    }
    if (found == null) return;
    for (final s in local.getSites(customerLocalId: localId)) {
      await deleteSite(s.localId);
    }
    if (found.serverId == null) {
      await local.removeCustomer(localId);
    } else {
      await local.putCustomer(found.copyWith(deleted: true, dirty: true, updatedAt: DateTime.now()));
    }
  }

  Future<Site> saveSite({String? localId, required String customerLocalId, required String name, required String address}) async {
    final cust = local.getCustomers().firstWhere((e) => e.localId == customerLocalId);
    Site s;
    if (localId == null) {
      s = Site(localId: _uuid.v4(), customerLocalId: customerLocalId,
          customerServerId: cust.serverId, customerName: cust.name, name: name, address: address);
    } else {
      final old = local.getSites().firstWhere((e) => e.localId == localId);
      s = old.copyWith(name: name, address: address, customerLocalId: customerLocalId,
          customerServerId: cust.serverId, customerName: cust.name,
          updatedAt: DateTime.now(), dirty: true);
      for (final n in local.getNotes().where((n) => n.siteLocalId == localId)) {
        await local.putNote(n.copyWith(siteName: name, customerName: cust.name));
      }
    }
    await local.putSite(s);
    return s;
  }

  Future<void> deleteSite(String localId) async {
    Site? found;
    for (final e in local.getSites()) {
      if (e.localId == localId) found = e;
    }
    if (found == null) return;
    for (final n in local.getNotes().where((n) => n.siteLocalId == localId)) {
      await deleteNote(n.localId);
    }
    if (found.serverId == null) {
      await local.removeSite(localId);
    } else {
      await local.putSite(found.copyWith(deleted: true, dirty: true, updatedAt: DateTime.now()));
    }
  }


  Future<FieldNote> saveNote({String? localId, required String siteLocalId,
      required String title, required String description, required String location,
      DateTime? dateTime, required String status, String? photoLocalPath}) async {
    final site = local.getSites().firstWhere((e) => e.localId == siteLocalId);
    FieldNote n;
    if (localId == null) {
      n = FieldNote(localId: _uuid.v4(), siteLocalId: siteLocalId,
          siteServerId: site.serverId, siteName: site.name, customerName: site.customerName,
          title: title, description: description, location: location,
          dateTime: dateTime ?? DateTime.now(), status: status, photoLocalPath: photoLocalPath);
    } else {
      final old = local.getNotes().firstWhere((e) => e.localId == localId);
      n = old.copyWith(siteLocalId: siteLocalId, siteServerId: site.serverId,
          siteName: site.name, customerName: site.customerName,
          title: title, description: description, location: location,
          dateTime: dateTime, status: status, photoLocalPath: photoLocalPath,
          updatedAt: DateTime.now(), dirty: true);
    }
    await local.putNote(n);
    return n;
  }

  Future<void> deleteNote(String localId) async {
    FieldNote? found;
    for (final e in local.getNotes()) {
      if (e.localId == localId) found = e;
    }
    if (found == null) return;
    if (found.serverId == null) {
      await local.removeNote(localId);
    } else {
      await local.putNote(found.copyWith(deleted: true, dirty: true, updatedAt: DateTime.now()));
    }
  }

  Future<String> sync() async {
    if (!await online) return 'Offline - changes saved locally';
    if (!api.isLoggedIn) return 'Not logged in';
    for (final c in local.getDirtyCustomers()) {
      try {
        if (c.deleted && c.serverId != null) {
          await api.deleteCustomer(c.serverId!);
          await local.removeCustomer(c.localId);
        } else if (c.serverId == null) {
          final j = await api.createCustomer(c.toServerJson());
          await local.putCustomer(c.copyWith(serverId: j['id'] as int, dirty: false));
        } else if (!c.deleted) {
          await api.updateCustomer(c.serverId!, c.toServerJson());
          await local.putCustomer(c.copyWith(dirty: false));
        }
      } catch (_) {}
    }
    final custByLocal = {for (final c in local.getCustomers()) c.localId: c};
    for (final s in local.getDirtySites()) {
      try {
        if (s.deleted && s.serverId != null) {
          await api.deleteSite(s.serverId!);
          await local.removeSite(s.localId);
          continue;
        }
        final parent = custByLocal[s.customerLocalId];
        if (parent == null || parent.serverId == null) continue;
        final body = {'name': s.name, 'address': s.address, 'customerId': parent.serverId};
        if (s.serverId == null) {
          final j = await api.createSite(body);
          await local.putSite(s.copyWith(serverId: j['id'] as int,
              customerServerId: parent.serverId, customerName: parent.name, dirty: false));
        } else if (!s.deleted) {
          await api.updateSite(s.serverId!, body);
          await local.putSite(s.copyWith(dirty: false, customerServerId: parent.serverId));
        }
      } catch (_) {}
    }
    final siteByLocal = {for (final s in local.getSites()) s.localId: s};
    for (final n in local.getDirtyNotes()) {
      try {
        if (n.deleted && n.serverId != null) {
          await api.deleteNote(n.serverId!);
          await local.removeNote(n.localId);
          continue;
        }
        final site = siteByLocal[n.siteLocalId];
        if (site == null || site.serverId == null) continue;
        final body = {
          'siteId': site.serverId, 'title': n.title, 'description': n.description,
          'location': n.location,
          'dateTime': (n.dateTime ?? n.updatedAt).toUtc().toIso8601String(),
          'status': n.status,
          if (n.photoLocalPath != null) 'photoPath': n.photoLocalPath,
        };
        if (n.serverId == null) {
          final j = await api.createNote(body);
          await local.putNote(n.copyWith(serverId: j['id'] as int, dirty: false));
        } else if (!n.deleted) {
          await api.updateNote(n.serverId!, body);
          await local.putNote(n.copyWith(dirty: false));
        }
      } catch (_) {}
    }
    await pull();
    final pending = pendingCount();
    return pending == 0 ? 'Synced' : 'Partially synced ($pending pending)';
  }

  Future<void> pull() async {
    final customers = await api.getCustomers();
    final sites = await api.getSites();
    final noteList = await api.getNotes();
    final existingCust = {for (final c in local.getCustomers()) c.serverId: c};
    final custLocalByServer = <int, String>{};
    for (final raw in customers) {
      final j = Map<String, dynamic>.from(raw as Map);
      final id = j['id'] as int;
      final localId = existingCust[id]?.localId ?? 'srv-$id';
      custLocalByServer[id] = localId;
      final existing = existingCust[id];
      if (existing != null && existing.dirty) continue;
      await local.putCustomer(Customer.fromServer({...j, 'localId': localId}));
    }
    final existingSite = {for (final s in local.getSites()) s.serverId: s};
    final siteLocalByServer = <int, String>{};
    for (final raw in sites) {
      final j = Map<String, dynamic>.from(raw as Map);
      final id = j['id'] as int;
      final localId = existingSite[id]?.localId ?? 'srv-$id';
      siteLocalByServer[id] = localId;
      final existing = existingSite[id];
      if (existing != null && existing.dirty) continue;
      final custLocal = custLocalByServer[j['customerId'] as int] ?? 'srv-${j['customerId']}';
      final fromSrv = Site.fromServer({...j, 'localId': localId});
      await local.putSite(fromSrv.copyWith(customerLocalId: custLocal));
    }
    final existingNote = {for (final n in local.getNotes()) n.serverId: n};
    for (final raw in noteList) {
      final j = Map<String, dynamic>.from(raw as Map);
      final id = j['id'] as int;
      final existing = existingNote[id];
      if (existing != null && existing.dirty) continue;
      final siteLocal = siteLocalByServer[j['siteId'] as int] ?? 'srv-${j['siteId']}';
      final fromSrv = FieldNote.fromServer({...j, 'localId': existing?.localId ?? 'srv-$id'});
      final preservedPhoto = (fromSrv.photoLocalPath != null && fromSrv.photoLocalPath!.isNotEmpty)
          ? fromSrv.photoLocalPath
          : existing?.photoLocalPath;
      await local.putNote(fromSrv.copyWith(
        siteLocalId: siteLocal,
        photoLocalPath: preservedPhoto,
      ));
    }
  }

  int pendingCount() {
    return local.getDirtyCustomers().length +
        local.getDirtySites().length +
        local.getDirtyNotes().length;
  }
}

