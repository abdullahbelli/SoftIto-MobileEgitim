import 'league_member.dart';

/// Lig seviyesi modeli.
/// Tohum, Filiz, Tomurcuk, Çiçek, Yıldız kademeleri ve grup üyelerini barındırır.
class League {
  final String id;
  final String tier; // 'Tohum', 'Filiz', 'Tomurcuk', 'Çiçek', 'Yıldız'
  final String weekId; // '2026-W43'
  final int maxMembers;
  final List<LeagueMember> members;

  const League({
    required this.id,
    required this.tier,
    required this.weekId,
    this.maxMembers = 15,
    this.members = const [],
  });

  League copyWith({
    String? id,
    String? tier,
    String? weekId,
    int? maxMembers,
    List<LeagueMember>? members,
  }) {
    return League(
      id: id ?? this.id,
      tier: tier ?? this.tier,
      weekId: weekId ?? this.weekId,
      maxMembers: maxMembers ?? this.maxMembers,
      members: members ?? this.members,
    );
  }
}
