import 'package:flutter/material.dart';
import 'package:goyolingua/core/Services/database.dart';
import 'package:goyolingua/data/leccion_model.dart';
import 'package:goyolingua/pages/profile.dart';
import 'package:goyolingua/pages/teoria.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  // Mandamos a llamar a la función que nos regresa toda la información necesaria para cargar la tarjeta
  Future<List<MapEntry<String, Leccion>>> obtenerClasesParaTarjetas() async {
    return await DatabaseMethods().obtenerTodasLasLecciones();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Clases'),
        actions: [
          // Mismo codigo que para la parte del chatHome (solamente use el icono para cambiar a la parte del usuario)
          // Solamente comparten el elemento GestureDetector ya que asi nos gusto quetengan estilos distintas las pantallas
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ProfilePage()),
              );
            },
            child: Container(
              padding: const EdgeInsets.all(5),
              margin: EdgeInsets.only(right: screenWidth * 0.02),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                borderRadius: BorderRadius.circular(50),
              ),
              child: Icon(
                Icons.person,
                color: Theme.of(context).colorScheme.onPrimary,
                size: screenWidth * 0.07,
              ),
            ),
          ),
        ],
      ),
      //Construimos un widget en su estado mas reciente con FutureBuilder
      body: FutureBuilder<List<MapEntry<String, Leccion>>>(
        future: obtenerClasesParaTarjetas(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No hay clases disponibles.'));
          }

          final lecciones = snapshot.data!;
          //ListView Para evitar desbordamientos
          return ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: lecciones.length,
            itemBuilder: (context, index) {
              final id = lecciones[index].key;
              final leccion = lecciones[index].value;

              return Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: ListTile(
                  title: Text(leccion.nombre),
                  subtitle: Text(leccion.texto.length > 50
                      ? '${leccion.texto.substring(0, 50)}...'
                      : leccion.texto),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  // Al darle click en la targetita nos enrutara a la parte de cargar la lecion
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => CargaLeccion(claseId: id),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
