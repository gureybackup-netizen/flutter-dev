class AppConstants {
  static const String appName = 'VardChat';
  static const String packageName = 'com.vardapp.vardchat';

  // Appwrite Configuration
  static const String appwriteEndpoint = 'https://cloud.appwrite.io/v1';
  static const String appwriteProjectId = '69fdfc680008d1295d17';
  static const String appwriteApiKey = 'standard_1bd886a318bec060893c9ffcaa88071c57c44980a979bdfc0053fb4e790101eabc2e324bfd4ba56f29a4a6a14d9dcc39468e9c55165b4374f8670bce79b9213fc9bdd5d9d5b279c34199aff634a69386aa275d83c70a70c289a1c963bb80ad876b89108559b0d546648cbeed8b12322126d6c7260f935f61b8254d81e66c427b';

  // Database IDs
  static const String databaseId = 'vardchat';
  static const String usersCollectionId = 'users';
  static const String conversationsCollectionId = 'conversations';
  static const String messagesCollectionId = 'messages';
  static const String callsCollectionId = 'calls';
}

class RouteConstants {
  static const String welcome = '/welcome';
  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/home';
  static const String conversations = '/conversations';
  static const String search = '/search';
  static const String chat = '/chat/:conversationId';
  static const String callOutgoing = '/call/outgoing/:callId';
  static const String callIncoming = '/call/incoming/:callId';
  static const String callActive = '/call/active/:callId';
  static const String settings = '/settings';
  static const String profileSettings = '/settings/profile';
  static const String privacyPolicy = '/settings/privacy';
  static const String terms = '/settings/terms';
  static const String callHistory = '/calls/history';
  static const String notificationSettings = '/settings/notifications';
  static const String securitySettings = '/settings/security';
}

class DatabaseConstants {
  static const String usersTable = 'users';
  static const String conversationsTable = 'conversations';
  static const String messagesTable = 'messages';
}

class ErrorMessages {
  static const String invalidCredentials = 'Invalid ID';
  static const String userNotFound = 'User not found';
  static const String connectionError = 'Connection error. Please try again.';
  static const String usernameInvalid = 'ID must be 8 characters';
}