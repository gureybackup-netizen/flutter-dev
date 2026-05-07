class VardCall {
  final String id;
  final String callerId;
  final String callerUsername;
  final String calleeUid;
  final String status;
  final String type;
  final DateTime createdAt;
  final DateTime? startedAt;
  final DateTime? endedAt;
  final int? durationSeconds;

  VardCall({
    required this.id,
    required this.callerId,
    required this.callerUsername,
    required this.calleeUid,
    required this.status,
    required this.type,
    required this.createdAt,
    this.startedAt,
    this.endedAt,
    this.durationSeconds,
  });

  factory VardCall.fromMap(Map<String, dynamic> map, String id) {
    return VardCall(
      id: id,
      callerId: map['caller_id'] ?? '',
      callerUsername: map['caller_username'] ?? '',
      calleeUid: map['callee_uid'] ?? '',
      status: map['status'] ?? 'ringing',
      type: map['type'] ?? 'voice',
      createdAt: DateTime.parse(map['created_at'] ?? DateTime.now().toIso8601String()),
      startedAt: map['started_at'] != null 
          ? DateTime.parse(map['started_at']) 
          : null,
      endedAt: map['ended_at'] != null 
          ? DateTime.parse(map['ended_at']) 
          : null,
      durationSeconds: map['duration_seconds'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'caller_id': callerId,
      'caller_username': callerUsername,
      'callee_uid': calleeUid,
      'status': status,
      'type': type,
      'created_at': createdAt.toIso8601String(),
      'started_at': startedAt?.toIso8601String(),
      'ended_at': endedAt?.toIso8601String(),
      'duration_seconds': durationSeconds,
    };
  }

  VardCall copyWith({
    String? status,
    DateTime? startedAt,
    DateTime? endedAt,
    int? durationSeconds,
  }) {
    return VardCall(
      id: id,
      callerId: callerId,
      callerUsername: callerUsername,
      calleeUid: calleeUid,
      status: status ?? this.status,
      type: type,
      createdAt: createdAt,
      startedAt: startedAt ?? this.startedAt,
      endedAt: endedAt ?? this.endedAt,
      durationSeconds: durationSeconds ?? this.durationSeconds,
    );
  }

  String get formattedDuration {
    if (durationSeconds == null || durationSeconds == 0) return '0:00';
    final minutes = durationSeconds! ~/ 60;
    final seconds = durationSeconds! % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }
}