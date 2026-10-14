import 'package:flutter_test/flutter_test.dart';
import 'package:fieldnotes_app/data/models/customer.dart';
import 'package:fieldnotes_app/data/models/site.dart';
import 'package:fieldnotes_app/data/models/field_note.dart';

void main() {
  test('Customer model round-trips through Map', () {
    final c = Customer(localId: 'abc', serverId: 1, name: 'Acme', contactInfo: 'x');
    final back = Customer.fromMap(c.toMap());
    expect(back.name, 'Acme');
    expect(back.serverId, 1);
  });

  test('Site keeps customer relation via localId', () {
    final s = Site(localId: 's1', customerLocalId: 'c1', name: 'HQ');
    expect(Site.fromMap(s.toMap()).customerLocalId, 'c1');
  });

  test('FieldNote keeps site relation and status', () {
    final n = FieldNote(localId: 'n1', siteLocalId: 's1', title: 'Visit', status: 'DONE');
    final back = FieldNote.fromMap(n.toMap());
    expect(back.siteLocalId, 's1');
    expect(back.status, 'DONE');
  });
}

