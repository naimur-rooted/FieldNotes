import 'package:hive_flutter/hive_flutter.dart';
import '../models/customer.dart';
import '../models/site.dart';
import '../models/field_note.dart';

/// Offline-first local store using Hive boxes of Maps.
/// Relations are kept via localIds so CRUD works fully offline.
class LocalStore {
  late Box _customers;
  late Box _sites;
  late Box _notes;

  static Future<LocalStore> init() async {
    await Hive.initFlutter();
    final s = LocalStore();
    s._customers = await Hive.openBox('customers');
    s._sites = await Hive.openBox('sites');
    s._notes = await Hive.openBox('notes');
    return s;
  }

  Future<void> clearAll() async {
    await _customers.clear();
    await _sites.clear();
    await _notes.clear();
  }

  // ---- Customers ----
  List<Customer> getCustomers() => _customers.values
      .map((e) => Customer.fromMap(Map.from(e as Map)))
      .where((c) => !c.deleted)
      .toList()
    ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));

  List<Customer> getDirtyCustomers() => _customers.values
      .map((e) => Customer.fromMap(Map.from(e as Map)))
      .where((c) => c.dirty)
      .toList();

  Future<void> putCustomer(Customer c) => _customers.put(c.localId, c.toMap());
  Future<void> removeCustomer(String localId) => _customers.delete(localId);

  // ---- Sites ----
  List<Site> getSites({String? customerLocalId}) {
    final all = _sites.values
        .map((e) => Site.fromMap(Map.from(e as Map)))
        .where((s) => !s.deleted)
        .toList()
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    if (customerLocalId == null) return all;
    return all.where((s) => s.customerLocalId == customerLocalId).toList();
  }

  List<Site> getDirtySites() => _sites.values
      .map((e) => Site.fromMap(Map.from(e as Map)))
      .where((s) => s.dirty)
      .toList();

  Future<void> putSite(Site s) => _sites.put(s.localId, s.toMap());
  Future<void> removeSite(String localId) => _sites.delete(localId);

  // ---- Notes ----
  List<FieldNote> getNotes({String? query, String? status, String? siteLocalId}) {
    final q = (query ?? '').trim().toLowerCase();
    return _notes.values
        .map((e) => FieldNote.fromMap(Map.from(e as Map)))
        .where((n) => !n.deleted)
        .where((n) => siteLocalId == null || n.siteLocalId == siteLocalId)
        .where((n) => status == null || status.isEmpty || n.status == status)
        .where((n) =>
            q.isEmpty ||
            n.title.toLowerCase().contains(q) ||
            n.description.toLowerCase().contains(q) ||
            n.siteName.toLowerCase().contains(q) ||
            n.customerName.toLowerCase().contains(q))
        .toList()
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
  }

  List<FieldNote> getDirtyNotes() => _notes.values
      .map((e) => FieldNote.fromMap(Map.from(e as Map)))
      .where((n) => n.dirty)
      .toList();

  Future<void> putNote(FieldNote n) => _notes.put(n.localId, n.toMap());
  Future<void> removeNote(String localId) => _notes.delete(localId);
}
