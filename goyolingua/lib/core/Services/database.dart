import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import 'package:goyolingua/data/leccion_model.dart';

class DatabaseMethods {
  Future addUser(Map<String, dynamic> userInfoMap, String id) async {
    return await FirebaseFirestore.instance
        .collection("users")
        .doc(id)
        .set(userInfoMap);
  }

  Future<DocumentSnapshot> getUserById(String uid) async {
    return await FirebaseFirestore.instance.collection("users").doc(uid).get();
  }

  Future<String?> subirImagenUsuario(File imagen, String userId) async {
    try {
      final String uniqueImageId =
          "${userId}_${DateTime.now().millisecondsSinceEpoch}";

      final storageRef = FirebaseStorage.instance
          .ref()
          .child("userImages")
          .child("$uniqueImageId.jpg");

      UploadTask uploadTask = storageRef.putFile(imagen);
      TaskSnapshot snapshot = await uploadTask;
      String downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      return null;
    }
  }

  Future addMessage(String chatRoomId, String messageId,
      Map<String, dynamic> messageInfoMap) async {
    return await FirebaseFirestore.instance
        .collection("chatrooms")
        .doc(chatRoomId)
        .collection("chats")
        .doc(messageId)
        .set(messageInfoMap);
  }

  Future<QuerySnapshot> Search(String username) async {
    return await FirebaseFirestore.instance
        .collection("users")
        .where("SearchKey", isEqualTo: username.substring(0, 1).toUpperCase())
        .get();
  }

  createChatRoom(
      String chatRoomId, Map<String, dynamic> chatRoomInfoMap) async {
    final snapshot = await FirebaseFirestore.instance
        .collection("chatrooms")
        .doc(chatRoomId)
        .get();
    if (snapshot.exists) {
      return true;
    } else {
      return FirebaseFirestore.instance
          .collection("chatrooms")
          .doc(chatRoomId)
          .set(chatRoomInfoMap);
    }
  }

  Future<bool> getChatRoom(chatRoomId) async {
    final snapshot = await FirebaseFirestore.instance
        .collection("chatrooms")
        .doc(chatRoomId)
        .get();
    if (snapshot.exists) {
      return true;
    } else {
      return false;
    }
  }

  Future<Stream<QuerySnapshot>> getChatRoomMessages(chatRoomId) async {
    return await FirebaseFirestore.instance
        .collection("chatrooms")
        .doc(chatRoomId)
        .collection("chats")
        .orderBy("time", descending: true)
        .snapshots();
  }

  Future<Stream<QuerySnapshot>> getAllTeachers() async {
    return await FirebaseFirestore.instance
        .collection('users')
        .where('eresMaestro', isEqualTo: true)
        .snapshots();
  }

  Future<Stream<QuerySnapshot>> getAllStudents() async {
    return await FirebaseFirestore.instance
        .collection('users')
        .where("eresMaestro", isEqualTo: false)
        .snapshots();
  }

  // Para actualizar la foto de perfil
  Future updateUser(String username, String urlImageNew) async {
    return await FirebaseFirestore.instance
        .collection("users")
        .where('username', isEqualTo: username)
        .get()
        .then((querySnapshot) {
      if (querySnapshot.docs.isNotEmpty) {
        querySnapshot.docs.first.reference.update({
          'Image': urlImageNew,
        });
      }
    });
  }

  /*                                  FUNCIONES PARA LA PARTE DE TEORIA Y DE EJERCICIOS                        */
  Future<List<MapEntry<String, Leccion>>> obtenerTodasLasLecciones() async {
    final snapshot =
        await FirebaseFirestore.instance.collection('clases').get();
    //Obtenidas todas las clases regresar en forma de lista
    return snapshot.docs.map((doc) {
      final leccion = Leccion.fromFirestore(doc.data() as Map<String, dynamic>);
      return MapEntry(doc.id, leccion);
    }).toList();
  }

  Future<Leccion> obtenerLeccion(String id) async {
    final doc =
        await FirebaseFirestore.instance.collection('clases').doc(id).get();
    if (!doc.exists) {
      throw Exception('La clase no existe');
    }
    return Leccion.fromFirestore(doc.data()!);
  }
}
