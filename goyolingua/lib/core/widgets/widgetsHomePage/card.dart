import 'package:flutter/material.dart';
import 'package:goyolingua/core/Services/database.dart';
import 'package:goyolingua/pages/chat_page.dart';

class PersonalCard extends StatelessWidget {
  final Map<String, dynamic> userData;
  final String? myUsername;
  final Function(String a, String b) getChatRoomIdbyUsername; //Funcion callback

  const PersonalCard({
    super.key,
    required this.userData,
    required this.myUsername,
    required this.getChatRoomIdbyUsername,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final username = userData["username"].toUpperCase();
    final name = userData["name"];
    final profileURL = userData["Image"];
    return GestureDetector(
      onTap: () async {
        var chatRoomId = getChatRoomIdbyUsername(
            myUsername!.toUpperCase(), username); // Ultima modificación
        Map<String, dynamic> chatInfoMap = {
          "users": [myUsername, username],
        };
        await DatabaseMethods().createChatRoom(chatRoomId, chatInfoMap);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatPage(
              name: name,
              profileurl: profileURL,
              username: username,
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        child: Material(
          // Queriamos un efecto coqueto para que se viera el boton con sombra abajo
          elevation: 5,
          borderRadius: BorderRadius.circular(10),
          child: Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: const Color.fromARGB(216, 94, 94, 94),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(60),
                  child: Image.network(
                    profileURL,
                    height: 70,
                    width: 70,
                    fit: BoxFit.cover,
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
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "$name",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: screenWidth * 0.02,
                        fontWeight: FontWeight.w500,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      softWrap: false,
                    ),
                    Text(
                      username == myUsername ? '$username (Soy Yo!)' : username,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: screenWidth * 0.025,
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
