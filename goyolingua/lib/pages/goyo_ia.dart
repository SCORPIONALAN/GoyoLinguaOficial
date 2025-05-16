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
    // Chatroom para que tu hables con goyito
    chatRoomid = "GOYITO@IA_${myUsername}";

    // Información del target y el sender (Target -> API de Goyito o mejor dicho su user. Sender -> El usuario corriente)
    Map<String, dynamic> chatInfoMap = {
      "users": [myUsername, "GOYITO@IA"],
    };
    // Si no existe el chat Goyito entonces crealo
    if (!await DatabaseMethods().getChatRoom(chatRoomid)) {
      await DatabaseMethods().createChatRoom(chatRoomid!, chatInfoMap);
    }
    setState(() {});
  }

  // Parte importante, ya que los Streams vienen reemplazando a los sockets, ya que estos tambien permiten comunicación en tiempo real
  getandSetMessages() async {
    messageStream = await DatabaseMethods().getChatRoomMessages(
        chatRoomid); // Traeme en todo momento los chats desde la base de datos y ordenados
    setState(() {});
  }

  // OnTheLoad Va a ser una función a la que vamos a cargar de toda la información que debe cargar si o si al momento de moverte a esta parte
  ontheload() async {
    await getthesharedpref(); // Obtener nuestro usuario actual
    await getandSetMessages(); // Obtener el stream de mensajes mandados y recibidos
  }

  //Envios del frontend al backend GOYITOAPI en render
  Future<void> sendMessageToBackend(String message) async {
    try {
      setState(() {
        _isLoading = true;
      });
      // Hacemos una peticion http, en este caso POST
      final response = await http.post(
        Uri.parse(backendUrl),
        headers: {
          'Content-Type':
              'application/json', // Mandamos información en formato JSON
        },
        //Que va a llevar? Va a llevar la pregunta, el user id y el username
        // el user id dentro del backend va a ir a una parte
        body: json.encode(
            {'question': message, 'uid': myUserId, 'username': myUsername}),
      );

      // El bot responde desde el backend al frontend mediante firebase
      if (response.statusCode != 200) {
        // Si algo falla tirame un error en forma de ventana emergente hacia abajo
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al comunicarse con la IA')),
        );
      }
    } catch (e) {
      // Si algo sale mal, entonces muestra el mensaje de error en la conexion
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error de conexión')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
      //Independiente si todo esta bien o mal, tenemos que finalizar el proceso para que podamos mandar otro mensaje y no se quede atascado
    }
  }

  // Mensaje por parte del usuario
  addMessage(bool sendClicked) async {
    // No se esta mandando mensaje y el input no esta vacio, procede a...
    if (!_isLoading && messagecontroller.text != "") {
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
  void initState() {
    super.initState();
    ontheload();
  }

  /*            MOSTRAR LOS MENSAJES                    */

  // Widget que guarda el mensaje dentro de un contenedor que dependiendo de si es mio o del otro cambia el formato y color
  Widget chatMessageTile(BuildContext context, dynamic data, bool sendByMe) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Row(
      mainAxisAlignment: sendByMe
          ? MainAxisAlignment.end
          : MainAxisAlignment
              .start, // Si es mio muestralo a la derecha, si no lo es muestra a la izquierda
      children: [
        Flexible(
            child: Container(
          padding: EdgeInsets.all(16),
          margin: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(24),
                  bottomRight: sendByMe
                      ? Radius.circular(0)
                      : Radius.circular(
                          24), // No redondees el extremo derecho inferior si el mensaje es mio
                  topRight: Radius.circular(24),
                  bottomLeft: sendByMe
                      ? Radius.circular(24)
                      : Radius.circular(
                          0)), // No redondees el extremo izquierdo inferior si es mensaje no es mio
              color: sendByMe
                  ? Theme.of(context)
                      .colorScheme
                      .secondary // Lo mande yo? mandame un color azul
                  : Theme.of(context)
                      .colorScheme
                      .onSecondary), // no lo mande yo? mandamelo en un color moradito
          // Inyectamos el mensaje independientemente si es mio o no
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

  // El stream va a traer todos los mensajes entre la IA y el usuario que la consulta en tiempo real
  Widget chatMessage() {
    return StreamBuilder(
        stream: messageStream,
        builder: (context, AsyncSnapshot snapshot) {
          return snapshot.hasData // Existe información?
              ? ListView.builder(
                  padding: EdgeInsets.only(bottom: 70),
                  itemCount: snapshot.data.docs
                      .length, // Accede a cada item del documento del stream
                  reverse: true,
                  itemBuilder: (context, index) {
                    // Por cada item ...
                    DocumentSnapshot ds = snapshot
                        .data.docs[index]; //obten el mensaje del index pedido
                    bool isSentByMe = myUsername == ds["sendBy"];
                    return chatMessageTile(context, ds,
                        isSentByMe); // hay que pasarle el contexto, el document snapshot (cierto mensaje), es mandado por mi ese cierto mensaje?
                  })
              : Center(
                  child: CircularProgressIndicator()); //Carga en lo que se crea
        });
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
              /*                        ENCABEZADO DE GOYITOIA                   */
              Padding(
                padding: const EdgeInsets.only(left: 10, top: 10),
                child: Row(
                  children: [
                    /*                        FOTO DE PERFIL DE NUESTRO QUERIDO GOYITO             */
                    CircleAvatar(
                      radius: screenWidth * 0.06,
                      backgroundImage: NetworkImage(widget
                          .profileurl), //Obtenemos el URL del widget, recordemos que esta información la mandamos en el navigator.dart
                    ),
                    SizedBox(width: 10),
                    // Nombre de GOYITO
                    Flexible(
                      child: Container(
                        margin: EdgeInsets.only(right: 10),
                        child: Text(
                          widget.name, // NOMBRE DE GOYITO
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onPrimary,
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
                    child: chatMessage(), // Contenedor que carga los mensajes
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
                      // Esta cargando? entonces no hagas nada, si si? entonces manda a llamar la funcion
                      onTap: _isLoading
                          ? null
                          : () {
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
                        child: _isLoading //Efecto en caso de enviar mensaje
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
