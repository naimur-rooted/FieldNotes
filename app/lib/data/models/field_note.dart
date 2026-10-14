class FieldNote {
  final String localId;
  final int? serverId;
  final String siteLocalId;
  final int? siteServerId;
  final String siteName;
  final String customerName;
  final String title;
  final String description;
  final String location;
  final DateTime? dateTime;
  final String status;
  final String? photoLocalPath;
  final DateTime updatedAt;
  final bool dirty;
  final bool deleted;

  FieldNote({
    required this.localId,
    this.serverId,
    required this.siteLocalId,
    this.siteServerId,
    this.siteName = '',
    this.customerName = '',
    required this.title,
    this.description = '',
    this.location = '',
    this.dateTime,
    this.status = 'OPEN',
    this.photoLocalPath,
    DateTime? updatedAt,
    this.dirty = true,
    this.deleted = false,
  }) : updatedAt = updatedAt ?? DateTime.now();

  FieldNote copyWith({
    String? localId, int? serverId, String? siteLocalId, int? siteServerId,
    String? siteName, String? customerName, String? title, String? description,
    String? location, DateTime? dateTime, String? status, String? photoLocalPath,
    DateTime? updatedAt, bool? dirty, bool? deleted,
  }) =>
      FieldNote(
        localId: localId ?? this.localId,
        serverId: serverId ?? this.serverId,
        siteLocalId: siteLocalId ?? this.siteLocalId,
        siteServerId: siteServerId ?? this.siteServerId,
        siteName: siteName ?? this.siteName,
        customerName: customerName ?? this.customerName,
        title: title ?? this.title,
        description: description ?? this.description,
        location: location ?? this.location,
        dateTime: dateTime ?? this.dateTime,
        status: status ?? this.status,
        photoLocalPath: photoLocalPath ?? this.photoLocalPath,
        updatedAt: updatedAt ?? this.updatedAt,
        dirty: dirty ?? this.dirty,
        deleted: deleted ?? this.deleted,
      );

  Map<String, dynamic> toMap() => {
        'localId': localId, 'serverId': serverId,
        'siteLocalId': siteLocalId, 'siteServerId': siteServerId,
        'siteName': siteName, 'customerName': customerName,
        'title': title, 'description': description, 'location': location,
        'dateTime': dateTime?.toIso8601String(), 'status': status,
        'photoLocalPath': photoLocalPath,
        'updatedAt': updatedAt.toIso8601String(), 'dirty': dirty, 'deleted': deleted,
      };

  factory FieldNote.fromMap(Map m) => FieldNote(
        localId: m['localId'] as String,
        serverId: m['serverId'] as int?,
        siteLocalId: m['siteLocalId'] as String,
        siteServerId: m['siteServerId'] as int?,
        siteName: (m['siteName'] ?? '') as String,
        customerName: (m['customerName'] ?? '') as String,
        title: m['title'] as String,
        description: (m['description'] ?? '') as String,
        location: (m['location'] ?? '') as String,
        dateTime: m['dateTime'] == null ? null : DateTime.tryParse(m['dateTime'] as String),
        status: (m['status'] ?? 'OPEN') as String,
        photoLocalPath: m['photoLocalPath'] as String?,
        updatedAt: DateTime.parse(m['updatedAt'] as String),
        dirty: (m['dirty'] ?? false) as bool,
        deleted: (m['deleted'] ?? false) as bool,
      );

  factory FieldNote.fromServer(Map<String, dynamic> j) => FieldNote(
        localId: (j['localId'] as String?) ?? 'srv-${j['id']}',
        serverId: j['id'] as int?,
        siteLocalId: 'srv-${j['siteId']}',
        siteServerId: j['siteId'] as int?,
        siteName: (j['siteName'] ?? '') as String,
        customerName: (j['customerName'] ?? '') as String,
        title: j['title'] as String,
        description: (j['description'] ?? '') as String,
        location: (j['location'] ?? '') as String,
        dateTime: j['dateTime'] == null ? null : DateTime.tryParse(j['dateTime'] as String),
        status: (j['status'] ?? 'OPEN') as String,
        updatedAt: DateTime.tryParse(j['updatedAt'] as String? ?? '') ?? DateTime.now(),
        dirty: false, deleted: false,
      );
}
