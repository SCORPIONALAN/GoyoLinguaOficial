import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:goyolingua/core/Services/database.dart';
import 'package:goyolingua/core/Services/shared_pref.dart';
import 'package:goyolingua/navigator.dart';
import 'package:goyolingua/pages/complete_info.dart';

class AuthMethods {
  final FirebaseAuth auth = FirebaseAuth.instance;

  getCurrentUser() async {
    return await auth.currentUser;
  }

  signInWithGoogle(BuildContext context) async {
    final GoogleSignIn googleSignIn = GoogleSignIn();

    final GoogleSignInAccount? googleSignInAccount =
        await googleSignIn.signIn();
    if (googleSignInAccount == null) return;

    final GoogleSignInAuthentication googleAuth =
        await googleSignInAccount.authentication;

    final AuthCredential credential = GoogleAuthProvider.credential(
      idToken: googleAuth.idToken,
      accessToken: googleAuth.accessToken,
    );

    UserCredential result = await auth.signInWithCredential(credential);
    User? userDetails = result.user;

    if (userDetails == null) return;

    final uid = userDetails.uid;
    final email = userDetails.email!;
    final username = email.replaceAll("@aragon.unam.mx", "");
    final firstLetter = username.substring(0, 1).toUpperCase();
    // Zona de código para tirar error en caso de que no sea Aragonense
    final isAragon = email.endsWith("@aragon.unam.mx");
    if (!isAragon) {
      await auth.signOut();
      await googleSignIn.signOut(); // opcional: cerrar sesión automáticamente
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        backgroundColor: Colors.red,
        content: Text(
          "Perdón! solo los correos @aragon.unam.mx pueden iniciar sesión.",
          style: TextStyle(color: Colors.white),
        ),
      ));
      return;
    }

    // Verificar si ya existe el usuario en Firestore
    final userDoc = await DatabaseMethods().getUserById(uid);

    if (userDoc.exists) {
      // Usuario ya registrado guarda los datos localmente y lo redirige
      final userData = userDoc.data() as Map<String, dynamic>;

      await SharedpreferenceHelper().saveUserDisplayName(userData["name"]);
      await SharedpreferenceHelper().saveUserEmail(userData["email"]);
      await SharedpreferenceHelper().saveUserId(userData["Id"]);
      await SharedpreferenceHelper().saveUserUserName(userData["username"]);
      await SharedpreferenceHelper().saveUserImage(userData["Image"]);
      await SharedpreferenceHelper()
          .saveUserIdiomaAprender(userData["idiomaAprender"]);
      await SharedpreferenceHelper()
          .saveUserIdiomaOrigen(userData["idiomaOrigen"]);
      await SharedpreferenceHelper().saveUserSexo(userData["sexo"]);
      await SharedpreferenceHelper()
          .saveUserEresMaestro(userData["eresMaestro"]);

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const Navegador()),
      );
    } else {
      // Si no existe me lo vas a redirigir a una pantalla a que complete sus datos
      // Y con el callback me los vas a salvar en userExtraData (idioma origen, idioma aprende, sexo, eres maestro? e imagen(opcional))
      final userExtraData = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CompleteProfileScreen(user: userDetails),
        ),
      );

      if (userExtraData == null) return;

      String? imageUrl;
      if (userExtraData["imagen"] != null) {
        // si el usuario agarro imagen, entonces...
        imageUrl = await DatabaseMethods().subirImagenUsuario(
            File(userExtraData["imagen"]),
            userDetails
                .uid); // subeme la imagen que selecciono mi user con su respectivo id de la autenticación
      }

      // completamos su información y la guardamos en las variables globales
      await SharedpreferenceHelper()
          .saveUserDisplayName(userDetails.displayName!);
      await SharedpreferenceHelper().saveUserEmail(userDetails.email!);
      await SharedpreferenceHelper().saveUserId(userDetails.uid);
      await SharedpreferenceHelper().saveUserUserName(username);
      await SharedpreferenceHelper()
          .saveUserIdiomaAprender(userExtraData["idiomaAprender"]);
      await SharedpreferenceHelper()
          .saveUserIdiomaOrigen(userExtraData["idiomaOrigen"]);
      await SharedpreferenceHelper().saveUserSexo(userExtraData["sexo"]);
      await SharedpreferenceHelper()
          .saveUserEresMaestro(userExtraData["eresMaestro"]);
      await SharedpreferenceHelper()
          .saveUserImage((imageUrl ?? userDetails.photoURL!));

      // cargamos su modelo para su subida a firebase
      Map<String, dynamic> userInfoMap = {
        "name": userDetails.displayName,
        "username": username.toUpperCase(),
        "email": email,
        "Image": imageUrl ?? userDetails.photoURL,
        "Id": userDetails.uid,
        "createdAt": userDetails.metadata.creationTime,
        "SearchKey": firstLetter,
        "idiomaAprender": userExtraData["idiomaAprender"],
        "idiomaOrigen": userExtraData["idiomaOrigen"],
        "eresMaestro": userExtraData["eresMaestro"],
        "sexo": userExtraData["sexo"]
      };

      // Creamos al usuario en firebase, donde el nombre del documento va a ser su user id
      await DatabaseMethods().addUser(userInfoMap, userDetails.uid);

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const Navegador()),
      );
    }
  }
}
