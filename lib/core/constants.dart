class AppConstants {
  static const String appName = 'VardChat';
  static const String packageName = 'com.vardapp.vardchat';
  static const String internalEmailDomain = 'localhost.test';

  static const String supabaseUrl = 'https://kmizmjgsmphsqweldzfq.supabase.co';
  static const String supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImttaXptamdzbXBoc3F3ZWxkemZxIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzgxNzI3NTUsImV4cCI6MjA5Mzc0ODc1NX0.bX70xWfBFmpP-roNmAccGXDCNNflUGeHfS7oE790yd8';

  static const String privateKeyStorageKey = 'e2e_private_key';
  static const String turnCredentialKey = 'turn_credentials';

  static const String stunServer = 'stun:stun.l.google.com:19302';
  static const String turnUrl = 'turn:global.relay.metered.ca:80';
  static const String turnUsername = 'demo';
  static const String turnCredential = 'demo';
}

class RouteConstants {
  static const String splash = '/splash';
  static const String welcome = '/welcome';
  static const String login = '/login';
  static const String register = '/register';
  static const String conversations = '/conversations';
  static const String search = '/search';
  static const String chat = '/chat/:conversationId';
  static const String callOutgoing = '/call/outgoing/:callId';
  static const String callIncoming = '/call/incoming/:callId';
  static const String callActive = '/call/active/:callId';
  static const String callHistory = '/calls/history';
  static const String settings = '/settings';
  static const String profileSettings = '/settings/profile';
  static const String notificationSettings = '/settings/notifications';
  static const String securitySettings = '/settings/security';
}

class DatabaseConstants {
  static const String usersTable = 'users';
  static const String usernamesTable = 'usernames';
  static const String conversationsTable = 'conversations';
  static const String messagesTable = 'messages';
  static const String callsTable = 'calls';
}

class ErrorMessages {
  static const String invalidCredentials = 'Invalid username or password';
  static const String usernameTaken = 'Username already taken';
  static const String connectionError = 'Connection error. Please try again.';
  static const String unableToDecrypt = 'Unable to decrypt';
  static const String usernameInvalid = 'Username must be 3-20 characters, lowercase letters, numbers, and underscores only';
  static const String passwordTooShort = 'Password must be at least 6 characters';
}