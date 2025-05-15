import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class CompleteProfileScreen extends StatefulWidget {
  final User user;

  const CompleteProfileScreen({required this.user, super.key});

  @override
  State<CompleteProfileScreen> createState() => _CompleteProfileScreenState();
}

class _CompleteProfileScreenState extends State<CompleteProfileScreen> {
  // Propiedades por default para que no cargue con errores
  String idiomaAprender = 'Inglés';
  String idiomaOrigen = 'Español';
  bool eresMaestro = false;
  File? imagenSeleccionada;
  String sexo = "Masculino";
  // Image Picker para obtener imagenes de la galeria
  final ImagePicker _picker = ImagePicker();

  // funcion obtenida de la documentacion oficial para seleccionar una imagen
  void pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        imagenSeleccionada = File(pickedFile.path);
      });
    }
  }

  // como es una función callback esta pantalla vamos a devolver los valores que esperabamos en un inicio para completar el perfil
  void guardarInformacion() {
    final datosFinales = {
      "idiomaAprender": idiomaAprender,
      "idiomaOrigen": idiomaOrigen,
      "eresMaestro": eresMaestro,
      "sexo": sexo,
      "imagen": imagenSeleccionada?.path,
    };

    Navigator.pop(context, datosFinales);
  }

  // Construccion final de lo que queremos
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Completa tu perfil")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    // Disque vamos a agregar en un futuro más lenguas, pero como solo es una, solo ponemos el ingles
                    DropdownButtonFormField<String>(
                      value: idiomaAprender,
                      decoration:
                          const InputDecoration(labelText: "Idioma a aprender"),
                      items: const ["Inglés"].map((lang) {
                        // En el arreglo se pueden agregar más idiomas, pera que los cargue
                        return DropdownMenuItem(value: lang, child: Text(lang));
                      }).toList(),
                      onChanged: (value) => setState(() {
                        idiomaAprender =
                            value!; // cachamos el valor del nuevo idioma a aprender
                      }),
                    ),
                    const SizedBox(height: 16),
                    // Por asi decirlo es la forma más completa a comparación de la anterior
                    DropdownButtonFormField<String>(
                      value: idiomaOrigen,
                      decoration:
                          const InputDecoration(labelText: "Idioma de origen"),
                      items: const ["Español", "Inglés"].map((lang) {
                        //Aqui ya hay 2 opciones
                        return DropdownMenuItem(value: lang, child: Text(lang));
                      }).toList(),
                      onChanged: (value) => setState(() {
                        idiomaOrigen =
                            value!; // una vez cambias el valor, agarra y renderiza el nuevo valor
                      }),
                    ),
                    const SizedBox(height: 16),
                    // Dropdown para 3 opciones
                    DropdownButtonFormField<String>(
                      value: sexo,
                      decoration:
                          const InputDecoration(labelText: "Elige tu sexo"),
                      items:
                          const ["Masculino", "Femenino", "Otro"].map((option) {
                        // Las posibles 3 opciones
                        return DropdownMenuItem(
                            value: option, child: Text(option));
                      }).toList(),
                      onChanged: (value) => setState(() {
                        sexo = value!; // Carga el nuevo elemento
                      }),
                    ),
                    const SizedBox(height: 16),
                    // Switch para un valor booleano, ya que preguntamos si eres maestro o no
                    // Investigando, el metodo adaptive hace una adaptación de este switch en base a la plataforma que estamos usando
                    SwitchListTile.adaptive(
                      title: const Text("¿Eres maestro?"),
                      value: eresMaestro,
                      onChanged: (value) => setState(() {
                        eresMaestro = value;
                      }),
                    ),
                    const SizedBox(height: 16),
                    OutlinedButton.icon(
                      icon: const Icon(Icons.image),
                      label: const Text("Seleccionar imagen (opcional)"),
                      onPressed: pickImage,
                    ),
                    // renderizado condicional donde si existe una imagen, entonces la vamos a mostrar
                    if (imagenSeleccionada != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 16),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(imagenSeleccionada!, height: 120),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                icon: const Icon(Icons.check),
                label: const Text("Guardar"),
                onPressed: guardarInformacion,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
