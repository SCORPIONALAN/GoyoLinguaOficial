import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:goyolingua/core/Services/database.dart';
import 'package:goyolingua/core/Services/shared_pref.dart';
import 'package:intl/intl.dart';
import 'package:random_string/random_string.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ChatIAPage extends StatefulWidget {
  String name, profileurl, username;
  ChatIAPage(
      {required this.name, required this.profileurl, required this.username});
  @override
  State<ChatIAPage> createState() => _ChatIAPageState();
}

class _ChatIAPageState extends State<ChatIAPage> {
  Stream? messageStream;
  String? myUsername,
      myName,
      myEmail,
      myPicture,
      chatRoomid,
      messageId,
      myUserId;
  TextEditingController messagecontroller = TextEditingController();
  bool _isLoading = false; // Para controlar estados de carga

  // URL del backend - Reemplaza con tu URL real
  final String backendUrl = 'https://goyolinguaapi.onrender.com/api/chat/ask';

  //Rescatar de Shared preferences nuestro usuario
  getthesharedpref() async {
    myUsername = await SharedpreferenceHelper.getUserUserName();
    myName = await SharedpreferenceHelper.getUserDisplayName();
    myEmail = await SharedpreferenceHelper.getUserEmail();
    myPicture = await SharedpreferenceHelper.getUserImage();
    myUserId = await SharedpreferenceHelper.getUserId();
    chatRoomid = "GOYITO@IA_${myUsername}";

    Map<String, dynamic> chatInfoMap = {
      "users": [myUsername, "GOYITO@IA"],
    };
    if (!await DatabaseMethods().getChatRoom(chatRoomid)) {
      await DatabaseMethods().createChatRoom(chatRoomid!, chatInfoMap);
    }
    setState(() {});
  }

  getandSetMessages() async {
    messageStream = await DatabaseMethods().getChatRoomMessages(chatRoomid);
    setState(() {});
  }

  ontheload() async {
    await getthesharedpref();
    await getandSetMessages();
  }

  @override
  void initState() {
    super.initState();
    ontheload();
  }

  /*            MOSTRAR LOS MENSAJES                    */
  Widget chatMessageTile(BuildContext context, dynamic data, bool sendByMe) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Row(
      mainAxisAlignment:
          sendByMe ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: [
        Flexible(
            child: Container(
          padding: EdgeInsets.all(16),
          margin: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(24),
                  bottomRight:
                      sendByMe ? Radius.circular(0) : Radius.circular(24),
                  topRight: Radius.circular(24),
                  bottomLeft:
                      sendByMe ? Radius.circular(24) : Radius.circular(0)),
              color: sendByMe
                  ? Theme.of(context).colorScheme.secondary
                  : Theme.of(context).colorScheme.onSecondary),
          child: Text(
            data["message"],
            style: TextStyle(
                color: Colors.white,
                fontSize: screenWidth * 0.035,
                fontWeight: FontWeight.w600),
          ),
        ))
      ],
    );
  }

  Widget chatMessage() {
    return StreamBuilder(
        stream: messageStream,
        builder: (context, AsyncSnapshot snapshot) {
          return snapshot.hasData
              ? ListView.builder(
                  padding: EdgeInsets.only(bottom: 70),
                  itemCount: snapshot.data.docs.length,
                  reverse: true,
                  itemBuilder: (context, index) {
                    DocumentSnapshot ds = snapshot.data.docs[index];
                    // Verifica si el mensaje fue enviado por el usuario actual
                    // Considera que la respuesta de la IA puede venir con sendBy o sendby
                    bool isSentByMe = myUsername == ds["sendBy"];
                    return chatMessageTile(context, ds, isSentByMe);
                  })
              : Center(child: CircularProgressIndicator());
        });
  }

  //Envios del frontend al backend
  Future<void> sendMessageToBackend(String message) async {
    try {
      setState(() {
        _isLoading = true;
      });

      final response = await http.post(
        Uri.parse(backendUrl),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode(
            {'question': message, 'uid': myUserId, 'username': myUsername}),
      );

      if (response.statusCode == 200) {
        // El bot responde desde el backend al frontend mediante firebase
        print("Mensaje enviado al backend correctamente");
      } else {
        ;
        // Manejo de error
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al comunicarse con la IA')),
        );
      }
    } catch (e) {
      print("Excepción al enviar mensaje: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error de conexión')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Mensaje por parte del usuario
  addMessage(bool sendClicked) async {
    if (messagecontroller.text != "") {
      String message = messagecontroller.text;
      messagecontroller.text = "";
      DateTime now = DateTime.now();
      String formattedDate = DateFormat('h:mma').format(now);

      // Crear el mapa de información del mensaje
      Map<String, dynamic> messageInfoMap = {
        "Data": "Message",
        "message": message,
        "sendBy": myUsername,
        "ts": formattedDate,
        "time": FieldValue.serverTimestamp(),
        "imgUrl": myPicture
      };

      messageId = randomAlphaNumeric(10);

      // Guardamos el mensaje del usuario
      await DatabaseMethods()
          .addMessage(chatRoomid!, messageId!, messageInfoMap);

      // Enviar el mensaje al backend para obtener respuesta de la IA
      await sendMessageToBackend(message);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        backgroundColor: Theme.of(context).colorScheme.primary,
        body: SafeArea(
          child: Column(
            children: [
              // Encabezado
              Padding(
                padding: const EdgeInsets.only(left: 10, top: 10),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: Icon(
                        Icons.arrow_back_ios_new_outlined,
                        color: Theme.of(context).colorScheme.onPrimary,
                      ),
                    ),
                    SizedBox(width: screenWidth / 7),
                    CircleAvatar(
                      radius: screenWidth * 0.04,
                      backgroundImage: NetworkImage(widget.profileurl),
                    ),
                    SizedBox(width: 10),
                    Flexible(
                      child: Container(
                        margin: EdgeInsets.only(right: 10),
                        child: Text(
                          widget.name,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: screenWidth * 0.05,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),

              SizedBox(height: 20),
              // Cuerpo del chat (mensajes)
              Expanded(
                child: Container(
                  width: screenWidth,
                  decoration: BoxDecoration(
                    color: Color.fromARGB(255, 250, 143, 55),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                    child: chatMessage(),
                  ),
                ),
              ),

              /*              AREA DE MI INPUT              */
              Container(
                color: Color.fromARGB(255, 250, 143, 55),
                padding: const EdgeInsets.only(
                    bottom: 10, left: 10, right: 10, top: 5),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Color.fromARGB(235, 255, 94, 0),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: TextField(
                          controller: messagecontroller,
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            hintText: "Escribe tu mensaje...",
                            hintStyle: const TextStyle(color: Colors.white70),
                            border: InputBorder.none,
                            contentPadding:
                                const EdgeInsets.symmetric(vertical: 14),
                          ),
                          cursorColor: Color.fromARGB(235, 255, 208, 0),
                          cursorRadius: const Radius.circular(30),
                        ),
                      ),
                    ),
                    SizedBox(width: 10),
                    GestureDetector(
                      onTap: () {
                        addMessage(true);
                      },
                      child: Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        decoration: BoxDecoration(
                          color: _isLoading
                              ? Colors.grey
                              : Theme.of(context).colorScheme.primary,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: _isLoading
                            ? SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color:
                                      Theme.of(context).colorScheme.onPrimary,
                                ),
                              )
                            : Text(
                                "Envia!",
                                style: TextStyle(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onPrimary),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
