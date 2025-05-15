import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:goyolingua/core/widgets/widgetsHomePage/card.dart';

class TeachersList extends StatelessWidget {
  final Stream<QuerySnapshot>? teachersStream;
  final String? myUsername;
  final Function(String a, String b) getChatRoomIdbyUsername;

  const TeachersList({
    super.key,
    required this.teachersStream,
    required this.myUsername,
    required this.getChatRoomIdbyUsername,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: teachersStream == null
          ? const Center(child: CircularProgressIndicator())
          : StreamBuilder<QuerySnapshot>(
              stream: teachersStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return const Center(
                      child: Text('Error al cargar los maestros'));
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(
                      child: Text('No hay maestros disponibles'));
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
