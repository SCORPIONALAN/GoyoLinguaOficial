import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:goyolingua/core/widgets/widgetsHomePage/card.dart';

class StudentsList extends StatelessWidget {
  final Stream<QuerySnapshot>? StudentsStream;
  final String? myUsername;
  final Function(String a, String b) getChatRoomIdbyUsername;

  const StudentsList({
    super.key,
    required this.StudentsStream,
    required this.myUsername,
    required this.getChatRoomIdbyUsername,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: StudentsStream == null
          ? const Center(child: CircularProgressIndicator())
          : StreamBuilder<QuerySnapshot>(
              stream: StudentsStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return const Center(
                      child: Text('Error al cargar los alumnos'));
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(
                      child: Text('No hay ningun alumno conectado!'));
                }

                return ListView.builder(
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    var userData = snapshot.data!.docs[index].data()
                        as Map<String, dynamic>;
                    return PersonalCard(
                      userData: userData,
                      myUsername: myUsername,
                      getChatRoomIdbyUsername: getChatRoomIdbyUsername,
                    );
                  },
                );
              },
            ),
    );
  }
}
