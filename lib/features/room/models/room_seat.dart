class RoomSeat {
  final int seatIndex;
  final String? userId;
  final String? displayName;
  final bool isMuted;
  final bool isLocked;

  const RoomSeat({
    required this.seatIndex,
    required this.userId,
    required this.displayName,
    required this.isMuted,
    required this.isLocked,
  });

  bool get isOccupied => userId != null;

  factory RoomSeat.fromMap(Map<String, dynamic> row) {
    return RoomSeat(
      seatIndex: (row['seat_index'] as num).toInt(),
      userId: row['user_id'] as String?,
      displayName: row['display_name'] as String?,
      isMuted: row['is_muted'] as bool? ?? false,
      isLocked: row['is_locked'] as bool? ?? false,
    );
  }
}
