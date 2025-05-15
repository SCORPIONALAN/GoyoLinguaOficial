import 'package:flutter/material.dart';
import 'package:goyolingua/pages/Home.dart';
import 'package:goyolingua/pages/chat_home_page.dart';
import 'package:goyolingua/pages/goyo_ia.dart';

/*              CÓDIGO SACADO DE LA FRANKIE ADAPTADO A LAS NECESIDADES ACTUALES DE LA APP            */

class Navegador extends StatefulWidget {
  const Navegador({super.key});

  @override
  State<Navegador> createState() => _NavegadorState();
}

class _NavegadorState extends State<Navegador> {
  int _indexActual = 0;

  final List<Widget> _pantallas = [
    const HomePage(), //Pantalla de ejercicios
    const ChatHomePage(), //pantalla de chats
    ChatIAPage(
        name: "GOYITOIA",
        profileurl:
            "https://firebasestorage.googleapis.com/v0/b/scorplingua.firebasestorage.app/o/Images%2FAssets%2FGoyitoIA.webp?alt=media&token=4ebb747f-05e0-4e6b-a711-d329ed420cac",
        username: "GOYITO@IA")
  ];

  void _cambiarPantalla(int index) {
    setState(() {
      _indexActual = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pantallas[_indexActual],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _indexActual,
        onTap: _cambiarPantalla,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Inicio',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat),
            label: 'Chat',
          ),
          //TODO Hacer el BottomNavigationBarItem para el chat con la IA y en dado caso las estadisticas
          BottomNavigationBarItem(icon: Icon(Icons.android), label: "GoyoSeek")
        ],
      ),
    );
  }
}
