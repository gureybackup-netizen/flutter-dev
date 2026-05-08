import 'package:appwrite/appwrite.dart';

void main() async {
  final client = Client()
      .setEndpoint('https://cloud.appwrite.io/v1')
      .setProject('69fdfc680008d1295d17')
      .addHeader('X-Appwrite-Key', 'standard_1bd886a318bec060893c9ffcaa88071c57c44980a979bdfc0053fb4e790101eabc2e324bfd4ba56f29a4a6a14d9dcc39468e9c55165b4374f8670bce79b9213fc9bdd5d9d5b279c34199aff634a69386aa275d83c70a70c289a1c963bb80ad876b89108559b0d546648cbeed8b12322126d6c7260f935f61b8254d81e66c427b');

  final databases = Databases(client);

  try {
    // Add public_key attribute to users collection
    await databases.createStringAttribute(
      databaseId: 'vardchat',
      collectionId: 'users',
      key: 'public_key',
      size: 256,
      required: false,
    );
    print('Successfully added public_key attribute!');
  } catch (e) {
    print('Error: $e');
    if (e.toString().contains('already exists')) {
      print('Attribute already exists - that\'s fine!');
    }
  }
}