class Customer {
  final String localId; // uuid, stable across sync
  final int? serverId;
  final String name;
  final String contactInfo;
  final DateTime updatedAt;
  final bool dirty; // needs sync
  final bool deleted; // tombstone for sync

  Customer({
    required this.localId,
    this.serverId,
    required this.name,
    this.contactInfo = '',
    DateTime? updatedAt,
    this.dirty = true,
    this.deleted = false,
  }) : updatedAt = updatedAt ?? DateTime.now();

  Customer copyWith({
    String? localId, int? serverId, String? name, String? contactInfo,
    DateTime? updatedAt, bool? dirty, bool? deleted,
  }) =>
      Customer(
        localId: localId ?? this.localId,
        serverId: serverId ?? this.serverId,
        name: name ?? this.name,
        contactInfo: contactInfo ?? this.contactInfo,
        updatedAt: updatedAt ?? this.updatedAt,
        dirty: dirty ?? this.dirty,
        deleted: deleted ?? this.deleted,
      );

  Map<String, dynamic> toMap() => {
        'localId': localId, 'serverId': serverId, 'name': name,
        'contactInfo': contactInfo, 'updatedAt': updatedAt.toIso8601String(),
        'dirty': dirty, 'deleted': deleted,
      };

  factory Customer.fromMap(Map m) => Customer(
        localId: m['localId'] as String,
        serverId: m['serverId'] as int?,
        name: m['name'] as String,
        contactInfo: (m['contactInfo'] ?? '') as String,
        updatedAt: DateTime.parse(m['updatedAt'] as String),
        dirty: (m['dirty'] ?? false) as bool,
        deleted: (m['deleted'] ?? false) as bool,
      );

  Map<String, dynamic> toServerJson() => {'name': name, 'contactInfo': contactInfo};

  factory Customer.fromServer(Map<String, dynamic> j) => Customer(
        localId: (j['localId'] as String?) ?? 'srv-${j['id']}',
        serverId: j['id'] as int?,
        name: j['name'] as String,
        contactInfo: (j['contactInfo'] ?? '') as String,
        updatedAt: DateTime.tryParse(j['updatedAt'] as String? ?? '') ?? DateTime.now(),
        dirty: false, deleted: false,
      );
}
