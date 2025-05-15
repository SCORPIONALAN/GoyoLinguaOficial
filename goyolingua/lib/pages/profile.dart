import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:goyolingua/core/Services/shared_pref.dart';
import 'package:goyolingua/pages/onboarding.dart';
import 'package:image_picker/image_picker.dart';
import 'package:goyolingua/core/Services/profile_utils.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String? myUsername, myName, myEmail, myPicture;
  File? selectedImage;
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    myUsername = await SharedpreferenceHelper.getUserUserName();
    myName = await SharedpreferenceHelper.getUserDisplayName();
    myEmail = await SharedpreferenceHelper.getUserEmail();
    myPicture = await SharedpreferenceHelper.getUserImage();
    setState(() {});
  }

  // Funcion para cambiar la imagen de perfil
  Future<void> _changeProfilePicture() async {
    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text("Seleccionar imagen"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Aqui es un widget que permite agregar ya sea imagenes de la galeria o de las fotos
            _buildImageOption(
                Icons.photo_library,
                "Galería",
                ImageSource
                    .gallery), // Si llegamos a habilitar la camara solo cambiamos el ImageSource a camara
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancelar"),
          ),
        ],
      ),
    );
  }

  //                Widget que permite cargar imagenes o subir desde la camara (pero no habilitamos la camara)
  //                    Solamente tenemos la galeria, pero de aqui vamos a guardar todo y subiremos la imagen a firebase
  ListTile _buildImageOption(IconData icon, String title, ImageSource source) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      onTap: () async {
        Navigator.pop(context);
        final XFile? image =
            await _picker.pickImage(source: source); // imagen seleccionada
        if (image != null) {
          await _uploadAndSaveProfilePicture(File(image.path));
        }
      },
    );
  }

  // Subir la imagen a un bucket de Firebase
  Future<void> _uploadAndSaveProfilePicture(File imageFile) async {
    setState(() => _isLoading = true);
    try {
      // establecemos una instancia con el nombre personalizado dentro de un bucket
      final ref = FirebaseStorage.instance.ref().child(
          'userImages/${myUsername}_${DateTime.now().millisecondsSinceEpoch}.jpg');

      await ref.putFile(imageFile); // Esperamos a que se guarde sin problemas
      final imageUrl =
          await ref.getDownloadURL(); // obtenemos el link de donde se guardo

      //Funcion que cambia la imagen de la base de datos
      await updateUserImage(myUsername!, imageUrl);

      await SharedpreferenceHelper().saveUserImage(imageUrl);
      setState(() => myPicture = imageUrl);

      // Si todo sale bien entonces mostrar una barra hacia abajo indicando que se cargo
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Imagen de perfil actualizada')),
        );
      }
    } catch (e) {
      debugPrint('Error al subir imagen: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error al subir la imagen')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  /*                              PROCESO PARA CERRAR SESIÓN                     */
  Future<void> _signOut() async {
    try {
      // Proceso para efecto de carga
      setState(() => _isLoading = true);
      /*              LINEAS IMPORTANTES PARA CERRAR LA SESIÓN       */
      await GoogleSignIn()
          .disconnect(); // HAY QUE DESVINCULAR LA CUENTA DE GOOGLE
      await FirebaseAuth.instance.signOut(); // CERRAMOS LA SESIÓN DE FIREBASE
      await SharedpreferenceHelper()
          .clearUserData(); // LIMPIAMOS NUESTROS DATOS DE LA APLICACION
      // Retornamos a la pantalla de inicio
      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const Onboarding()),
        (route) => false,
      );
    } catch (e) {
      debugPrint('Error al cerrar sesión: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error al cerrar sesión')),
        );
      }
    } finally {
      // Sin importar si falla o no, debemos terminar el proceso de carga
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: const Color(0xFF2C2C2C),
      appBar: AppBar(
        title: const Text('Mi Perfil'),
        backgroundColor: const Color(0xFF3D3D3D),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.08),
            child: Column(
              children: [
                SizedBox(height: screenHeight * 0.05),
                _buildProfileImage(screenWidth),
                SizedBox(height: screenHeight * 0.03),
                _buildProfileItem(Icons.person, 'Nombre de usuario',
                    myUsername ?? 'Cargando...'),
                _buildProfileItem(
                    Icons.badge, 'Nombre completo', myName ?? 'Cargando...'),
                _buildProfileItem(Icons.email, 'Correo electrónico',
                    myEmail ?? 'Cargando...'),
                const SizedBox(height: 30),
                _buildSignOutButton(),
                SizedBox(height: screenHeight * 0.05),
              ],
            ),
          ),
          if (_isLoading)
            Container(
              color: Colors.black45,
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }

  // Widget para mostrar la imagen dentro del perfil
  Widget _buildProfileImage(double screenWidth) {
    return Stack(
      children: [
        // Contenedor para la imagen
        Container(
          width: screenWidth * 0.35,
          height: screenWidth * 0.35,
          // Decoraciones para que el circulo de la imagen sea naranja
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
                color: Theme.of(context).colorScheme.primary, width: 3),
          ),

          child: ClipOval(
            child: Image.network(
              myPicture!,
              fit: BoxFit.cover,
              //Funcion para mostrar una pantalla de carga
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Center(
                  child: CircularProgressIndicator(
                    value: loadingProgress.expectedTotalBytes != null
                        ? loadingProgress.cumulativeBytesLoaded /
                            loadingProgress.expectedTotalBytes!
                        : null,
                  ),
                );
              },
            ),
          ),
        ),
        // Icono de la camara posicionada abajo a la derecha donde si le das click puedes cambiar la imagen
        Positioned(
          bottom: 0,
          right: 0,
          child: GestureDetector(
            onTap:
                _changeProfilePicture, // Funcion para cambiar la foto de perfil
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.camera_alt,
                color: Theme.of(context).colorScheme.onPrimary,
                size: screenWidth * 0.06,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // Widget para los elementos de las tarjetitas de los datos del usuario
  Widget _buildProfileItem(IconData icon, String title, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color(0xFF3D3D3D),
        borderRadius: BorderRadius.circular(10),
        boxShadow: const [
          BoxShadow(
            color: Color.fromARGB(87, 0, 0, 0),
            spreadRadius: 1,
            blurRadius: 5,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, color: Theme.of(context).colorScheme.primary, size: 30),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: TextStyle(color: Colors.grey[400], fontSize: 14)),
                const SizedBox(height: 5),
                Text(value,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w500)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Widget para el boton de cerrar sesión
  Widget _buildSignOutButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red,
          padding: const EdgeInsets.symmetric(vertical: 15),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
        onPressed: () => showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text("Cerrar sesión"),
            content: const Text("¿Estás seguro de que quieres cerrar sesión?"),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Cancelar")),
              TextButton(
                  onPressed: _signOut, child: const Text("Cerrar sesión")),
            ],
          ),
        ),
        child: const Text("Cerrar sesión",
            style: TextStyle(color: Colors.white, fontSize: 16)),
      ),
    );
  }
}
