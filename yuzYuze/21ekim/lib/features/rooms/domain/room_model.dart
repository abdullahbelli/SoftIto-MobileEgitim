import 'dart:convert';

/// BoardConnect oda veri modeli
class RoomModel {
  final String id;
  final String name;
  final String ownerId;
  final String ownerName;
  final String joinCode;
  final String shareLink;
  final int maxParticipants;
  final int participantCount;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isDeleted;

  const RoomModel({
    required this.id,
    required this.name,
    required this.ownerId,
    required this.ownerName,
    required this.joinCode,
    required this.shareLink,
    this.maxParticipants = 10,
    this.participantCount = 1,
    required this.createdAt,
    required this.updatedAt,
    this.isDeleted = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'ownerId': ownerId,
      'ownerName': ownerName,
      'joinCode': joinCode,
      'shareLink': shareLink,
      'maxParticipants': maxParticipants,
      'participantCount': participantCount,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'isDeleted': isDeleted,
    };
  }

  factory RoomModel.fromMap(Map<String, dynamic> map) {
    return RoomModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      ownerId: map['ownerId'] ?? '',
      ownerName: map['ownerName'] ?? 'Oda Sahibi',
      joinCode: map['joinCode'] ?? '',
      shareLink: map['shareLink'] ?? '',
      maxParticipants: map['maxParticipants'] ?? 10,
      participantCount: map['participantCount'] ?? 1,
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'])
          : DateTime.now(),
      updatedAt: map['updatedAt'] != null
          ? DateTime.parse(map['updatedAt'])
          : DateTime.now(),
      isDeleted: map['isDeleted'] ?? false,
    );
  }

  String toJson() => json.encode(toMap());

  factory RoomModel.fromJson(String source) =>
      RoomModel.fromMap(json.decode(source));

  RoomModel copyWith({
    String? id,
    String? name,
    String? ownerId,
    String? ownerName,
    String? joinCode,
    String? shareLink,
    int? maxParticipants,
    int? participantCount,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isDeleted,
  }) {
    return RoomModel(
      id: id ?? this.id,
      name: name ?? this.name,
      ownerId: ownerId ?? this.ownerId,
      ownerName: ownerName ?? this.ownerName,
      joinCode: joinCode ?? this.joinCode,
      shareLink: shareLink ?? this.shareLink,
      maxParticipants: maxParticipants ?? this.maxParticipants,
      participantCount: participantCount ?? this.participantCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isDeleted: isDeleted ?? this.isDeleted,
    );
  }
}
