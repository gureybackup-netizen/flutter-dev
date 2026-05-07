class VardUser {
  final String id;
  final String username;
  final String displayName;
  final String publicKey;
  final String? fcmToken;
  final DateTime createdAt;
  final String themePreference;
  final bool notificationsEnabled;

  VardUser({
    required this.id,
    required this.username,
    required this.displayName,
    required this.publicKey,
    this.fcmToken,
    required this.createdAt,
    this.themePreference = 'dark',
    this.notificationsEnabled = true,
  });

  factory VardUser.fromMap(Map<String, dynamic> map, String id) {
    return VardUser(
      id: id,
      username: map['username'] ?? '',
      displayName: map['display_name'] ?? '',
      publicKey: map['public_key'] ?? '',
      fcmToken: map['fcm_token'],
      createdAt: DateTime.parse(map['created_at'] ?? DateTime.now().toIso8601String()),
      themePreference: map['theme_preference'] ?? 'dark',
      notificationsEnabled: map['notifications_enabled'] ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'username': username,
      'display_name': displayName,
      'public_key': publicKey,
      'fcm_token': fcmToken,
      'created_at': createdAt.toIso8601String(),
      'theme_preference': themePreference,
      'notifications_enabled': notificationsEnabled,
    };
  }

  VardUser copyWith({
    String? displayName,
    String? fcmToken,
    String? themePreference,
    bool? notificationsEnabled,
  }) {
    return VardUser(
      id: id,
      username: username,
      displayName: displayName ?? this.displayName,
      publicKey: publicKey,
      fcmToken: fcmToken ?? this.fcmToken,
      createdAt: createdAt,
      themePreference: themePreference ?? this.themePreference,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
    );
  }
}