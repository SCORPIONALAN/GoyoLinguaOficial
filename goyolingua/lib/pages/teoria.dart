import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:goyolingua/core/Services/database.dart';
import 'package:goyolingua/core/widgets/widgetsTeoria/muestra_teoria.dart';
import 'package:goyolingua/data/leccion_model.dart';

class CargaLeccion extends StatelessWidget {
  final String claseId;

  const CargaLeccion({Key? key, required this.claseId}) : super(key: key);

  Future<Leccion> obtenerLec(String id) async {
    return await DatabaseMethods().obtenerLeccion(id);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Leccion>(
      future: obtenerLec(claseId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
              body: Center(child: CircularProgressIndicator()));
        } else if (snapshot.hasError) {
          return Scaffold(
              body: Center(child: Text('Error: ${snapshot.error}')));
        } else if (snapshot.hasData) {
          final leccion = snapshot.data!;
          return MuestraTeoria(
            nombreLeccion: leccion.nombre,
            texto: leccion.texto,
            videoUrl: leccion.videoUrl,
            imagenUrl: leccion.imagenUrl,
          );
        } else {
          return const Scaffold(
              body: Center(child: Text('No se encontró la clase.')));
        }
      },
    );
  }
}
