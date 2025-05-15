import 'package:cloud_firestore/cloud_firestore.dart';

// Función para referenciar la nueva imagen en la base de datos (Pertenece a profile.dart)
Future<void> updateUserImage(String username, String imageUrl) async {
  final snapshot = await FirebaseFirestore.instance
      .collection("users")
      .where('username', isEqualTo: username)
      .get();

  if (snapshot.docs.isNotEmpty) {
    await snapshot.docs.first.reference.update({'Image': imageUrl});
  }
}
