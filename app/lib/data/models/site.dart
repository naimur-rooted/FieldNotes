class Site {
  final String localId;
  final int? serverId;
  final String customerLocalId; // relation via local id (offline-safe)
  final int? customerServerId;
  final String customerName; // denormalized display only
  final String name;
  final String address;
  final DateTime updatedAt;
  final bool dirty;
  final bool deleted;

  Site({
    required this.localId,
    this.serverId,
    required this.customerLocalId,
    this.customerServerId,
    this.customerName = '',
    required this.name,
    this.address = '',
    DateTime? updatedAt,
    this.dirty = true,
    this.deleted = false,
  }) : updatedAt = updatedAt ?? DateTime.now();

  Site copyWith({
    String? localId, int? serverId, String? customerLocalId, int? customerServerId,
    String? customerName, String? name, String? address,
    DateTime? updatedAt, bool? dirty, bool? deleted,
  }) =>
      Site(
        localId: localId ?? this.localId,
        serverId: serverId ?? this.serverId,
        customerLocalId: customerLocalId ?? this.customerLocalId,
        customerServerId: customerServerId ?? this.customerServerId,
        customerName: customerName ?? this.customerName,
        name: name ?? this.name,
        address: address ?? this.address,
        updatedAt: updatedAt ?? this.updatedAt,
        dirty: dirty ?? this.dirty,
        deleted: deleted ?? this.deleted,
      );

  Map<String, dynamic> toMap() => {
        'localId': localId, 'serverId': serverId,
        'customerLocalId': customerLocalId, 'customerServerId': customerServerId,
        'customerName': customerName, 'name': name, 'address': address,
        'updatedAt': updatedAt.toIso8601String(), 'dirty': dirty, 'deleted': deleted,
      };

  factory Site.fromMap(Map m) => Site(
        localId: m['localId'] as String,
        serverId: m['serverId'] as int?,
        customerLocalId: m['customerLocalId'] as String,
        customerServerId: m['customerServerId'] as int?,
        customerName: (m['customerName'] ?? '') as String,
        name: m['name'] as String,
        address: (m['address'] ?? '') as String,
        updatedAt: DateTime.parse(m['updatedAt'] as String),
        dirty: (m['dirty'] ?? false) as bool,
        deleted: (m['deleted'] ?? false) as bool,
      );

  factory Site.fromServer(Map<String, dynamic> j) => Site(
        localId: (j['localId'] as String?) ?? 'srv-${j['id']}',
        serverId: j['id'] as int?,
        customerLocalId: 'srv-${j['customerId']}',
        customerServerId: j['customerId'] as int?,
        customerName: (j['customerName'] ?? '') as String,
        name: j['name'] as String,
        address: (j['address'] ?? '') as String,
        updatedAt: DateTime.tryParse(j['updatedAt'] as String? ?? '') ?? DateTime.now(),
        dirty: false, deleted: false,
      );
}
