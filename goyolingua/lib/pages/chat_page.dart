import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:goyolingua/core/Services/chat_utils.dart';
import 'package:goyolingua/core/Services/database.dart';
import 'package:goyolingua/core/Services/shared_pref.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:random_string/random_string.dart';
import 'package:just_audio/just_audio.dart';

class ChatPage extends StatefulWidget {
  String name, profileurl, username;
  ChatPage(
      {required this.name, required this.profileurl, required this.username});
  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  // Variables con las que vamos a estar trabajando en todo el documento
  Stream?
      messageStream; // Stream para cargar en tiempo real los mensajes con ayuda de un StreamBuilder que referencie a los mensajes de un chatRoom
  String? myUsername,
      myName,
      myEmail,
      myPicture,
      chatRoomid,
      messageId; // Elementos necesarios para cargar a nuestra base de datos (Por asi decirlo es como nuestro modelo)
  File?
      selectedImage; // File de la imagen que un futuro agarraremos con imagepicker
  TextEditingController messagecontroller =
      TextEditingController(); // controlador para cachar el valor del input
  final ImagePicker _picker =
      ImagePicker(); // instancia de image Picker para poder entrar a la galeria

  // Audio player variables
  final AudioPlayer _audioPlayer =
      AudioPlayer(); // instancia de audio player para reproducir audio
  String?
      _currentlyPlayingUrl; // URL del audio que actualmente estas escuchando
  bool _isPlaying = false; // bandera para para el audio o continuarlo
  bool _isRecording =
      false; // Bandera que nos indica si acabamos o no de grabar
  String? _filePath; // Ruta del audio de nuestro dispositivo
  final FlutterSoundRecorder _recorder =
      FlutterSoundRecorder(); // instancia de la grabadora
  bool _recorderInitialized = false; // bandera para nuestra grabadora

  //Rescatar de Shared preferences nuestro usuario
  getthesharedpref() async {
    myUsername = await SharedpreferenceHelper.getUserUserName();
    myName = await SharedpreferenceHelper.getUserDisplayName();
    myEmail = await SharedpreferenceHelper.getUserEmail();
    myPicture = await SharedpreferenceHelper.getUserImage();
    chatRoomid = ChatUtils.getChatRoomIdByUsername(
        myUsername!,
        widget
            .username); //mi nombre y el valor que se le asigno al widget de username
    setState(() {});
  }

  // Funcion para obtener nuestro stream de mensajes que tienen en el chatRoom entre 2 personas
  getandSetMessages() async {
    messageStream = await DatabaseMethods().getChatRoomMessages(chatRoomid);
    setState(() {});
  }

  // Función para cargar los elementos más escenciales al iniciar esta parte de la app
  ontheload() async {
    await getthesharedpref();
    await getandSetMessages();
  }

  @override
  void initState() {
    super.initState();
    ontheload();
    _initialize();

    // Configurar el audio player para manejar eventos de finalización
    _audioPlayer.playerStateStream.listen((state) {
      if (state.processingState == ProcessingState.completed) {
        setState(() {
          _isPlaying = false;
        });
      }
    });
  }

  // Dispose sirve para cerrar el buffer o mejor dicho liberar los servicios
  // Para por ejemplo cerrar el contexto del microfono o cerrar el audio
  @override
  void dispose() {
    _recorder.closeRecorder();
    _audioPlayer.dispose();
    super.dispose();
  }

  /*                  PARTE DE LOS PERMISOS                            */
  Future<void> _initialize() async {
    try {
      // Solicitar permisos primero
      await _requestPermission();

      // Configurar el path para el archivo de audio
      var tempDir =
          await getTemporaryDirectory(); // Obten donde se guardo el audio
      _filePath =
          '${tempDir.path}/audio_${DateTime.now().millisecondsSinceEpoch}.aac'; // Crea una ruta del audio

      // Inicializar el grabador
      await _recorder.openRecorder();
      _recorderInitialized = true;
    } catch (e) {
      // Muestra un dialogo en caso de un error al inicializar la grabadora
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        backgroundColor: Colors.red,
        content: Text("Error al inicializar el grabador de audio: $e"),
      ));
    }
  }

  Future<void> _requestPermission() async {
    var status = await Permission.microphone.status;
    if (!status.isGranted) {
      await Permission.microphone.request(); // Permiso para el microfono
    }
    // solicitar permiso para acceder a la galeria
    await Permission.storage.request();
  }

  // Funcion cuando presiones el icono de grabar
  Future openRecording() => showDialog(
      context: context,
      // hacer pop Up para mostrar un apartado para cargar tu audio y subirlo
      builder: (context) => AlertDialog(
            title: Text(
              "Nota de voz",
              style: TextStyle(
                fontSize: 22.0,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
              textAlign: TextAlign.center,
            ),
            content: SingleChildScrollView(
              child: Container(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _isRecording
                          ? Icons.mic
                          : Icons
                              .mic_none, // Renderizado condicional cuando el microfono esta siendo usado o no
                      size: 50,
                      color: _isRecording
                          ? Colors.red
                          : Colors
                              .grey, // Renderizado condicional cuando el microfono esta siendo usado o no
                    ),
                    SizedBox(height: 20.0),
                    Text(
                      _isRecording
                          ? "Grabando..."
                          : "Presiona para grabar", // Renderizado condicional cuando el microfono esta siendo usado o no
                      style: TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 20.0),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        padding:
                            EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      ),
                      // Boton para iniciar y finalizar grabación
                      onPressed: () {
                        if (_isRecording) {
                          _stopRecording();
                        } else {
                          _startRecording();
                        }
                      },
                      child: Text(
                        _isRecording
                            ? "Detener grabación"
                            : "Iniciar grabación",
                        style: TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    // Boton para subir la grabación
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _isRecording
                            ? Colors.grey
                            : Theme.of(context).colorScheme.secondary,
                        padding:
                            EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      ),
                      onPressed: () {
                        if (_isRecording) {
                          // No hacer nada mientras graba
                        } else {
                          // En caso de que ya acabo de grabar dar la opción de subirlo a algun lado
                          _uploadFile();
                        }
                      },
                      child: Text(
                        "Enviar audio",
                        style: TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
            actions: [
              // Boton para cancelar o inclusive dar click en cualquier otro lado y cancelar todo
              TextButton(
                onPressed: () {
                  if (_isRecording) {
                    _stopRecording();
                  }
                  Navigator.pop(context);
                },
                child: Text(
                  "Cancelar",
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontSize: 16.0,
                  ),
                ),
              ),
            ],
          ));

  // Proceso de Grabacion (Inicio)
  Future<void> _startRecording() async {
    try {
      // Verificar si se inicia la grabacion
      if (!_recorderInitialized) {
        // Vuelve a pedir los permisos
        await _initialize();

        // Si aún no está inicializado, mostrar error
        if (!_recorderInitialized) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            backgroundColor: Colors.red,
            content: Text("No se pudo inicializar el grabador de audio"),
          ));
          return;
        }
      }

      // Verificar si el grabador está abierto
      if (!_recorder.isRecording) {
        await _recorder.startRecorder(
          toFile: _filePath,
          codec: Codec.aacADTS,
        );
        setState(() {
          _isRecording = true;
          Navigator.of(context).pop();
          openRecording();
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        backgroundColor: Colors.red,
        content: Text("Error al iniciar la grabación: $e"),
      ));
    }
  }

  // Proceso de Grabacion (Fin)
  Future<void> _stopRecording() async {
    try {
      if (_recorder.isRecording) {
        await _recorder
            .stopRecorder(); // Cuando acabemos de grabar deten la grabadora
      }

      setState(() {
        _isRecording = false;
        Navigator.of(context).pop();
        openRecording();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        backgroundColor: Colors.red,
        content: Text("Error al detener la grabación: $e"),
      ));
    }
  }

  // funciones para reproducir audio
  Future<void> _playAudio(String audioUrl) async {
    try {
      // Si ya estoy reproduciendo este audio, lo pauso
      if (_currentlyPlayingUrl == audioUrl && _isPlaying) {
        await _audioPlayer.pause();
        setState(() {
          _isPlaying = false;
        });
        return;
      }

      // Si estoy reproduciendo otro audio, lo detengo completamente
      if (_isPlaying) {
        await _audioPlayer.stop();
        setState(() {
          _isPlaying = false;
        });
      }

      // Siempre configuramos el audio desde cero para asegurar que empiece desde el principio
      await _audioPlayer.setUrl(audioUrl);
      _currentlyPlayingUrl = audioUrl;

      // Pequeña pausa para asegurar que el audio se ha cargado correctamente
      await Future.delayed(Duration(milliseconds: 50));

      // Reproducir desde el principio
      await _audioPlayer.seek(Duration.zero);
      await _audioPlayer.play();
      setState(() {
        _isPlaying = true;
      });
      // Configurar un listener para cuando termine la reproducción
      _audioPlayer.playerStateStream.listen((playerState) {
        if (playerState.processingState == ProcessingState.completed) {
          setState(() {
            _isPlaying = false;
          });
        }
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        backgroundColor: Colors.red,
        content: Text("Error al reproducir el audio: $e"),
      ));
    }
  }

  /*                          OBTEN LA IMAGEN DE TU GALERIA O CAMARA                               */
  Future getImage() async {
    /*        ESTE PopUp era originalmente para dar opciones entre la galeria o la camara, pero no pude resolver temas de la camara */
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Seleccionar imagen"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.photo_library),
                title: Text("Galería"),
                onTap: () async {
                  Navigator.pop(context);
                  await _getImageFromGallery();
                },
              ),
              // Aqui iba para las fotos, pero me marcaba errores asi que la quite
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text("Cancelar"),
            ),
          ],
        );
      },
    );
  }

  Future _getImageFromGallery() async {
    final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery); // Otener la imagen con imagePicker
    if (image != null) {
      setState(() {
        selectedImage = File(image.path);
      });
      await _uploadImage();
    }
  }

  /*            SUBIR EL ARCHIVO DE AUDIO           */
  Future<void> _uploadFile() async {
    try {
      // Verificar que tengamos un archivo grabado
      if (_filePath == null) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          backgroundColor: Colors.red,
          content: Text(
            "Error: No se ha grabado ningún audio",
            style: TextStyle(fontSize: 16),
          ),
        ));
        return;
      }

      // Verificar que el archivo exista
      File file = File(_filePath!);
      if (!file.existsSync()) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          backgroundColor: Colors.red,
          content: Text(
            "Error: El archivo de audio no existe en el dispositivo",
            style: TextStyle(fontSize: 16),
          ),
        ));
        return;
      }

      // Comprobar el tamaño del archivo
      int fileSize = await file.length();
      if (fileSize <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          backgroundColor: Colors.red,
          content: Text(
            "Error: El archivo de audio está vacío",
            style: TextStyle(fontSize: 16),
          ),
        ));
        return;
      }
      // Mostrar mensaje de carga
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        backgroundColor: Colors.amber,
        content: Text(
          "Tu audio se está subiendo, por favor espera",
          style: TextStyle(fontSize: 16),
        ),
      ));

      // Generar un ID único para el audio
      String audioId = randomAlphaNumeric(10);

      // Subir archivo a Firebase Storage
      Reference ref = FirebaseStorage.instance
          .ref()
          .child("Audio")
          .child("Usuarios")
          .child("$audioId.aac");

      UploadTask uploadTask = ref.putFile(file);

      // Esperar a que se complete la carga
      TaskSnapshot snapshot = await uploadTask;
      String downloadURL = await snapshot.ref.getDownloadURL();

      // Crear el mensaje en Firestore
      DateTime now = DateTime.now();
      String formattedDate = DateFormat('h:mma').format(now);

      Map<String, dynamic> messageInfoMap = {
        "Data": "Audio", // Asegurarnos que el tipo sea Audio
        "message": downloadURL,
        "sendBy": myUsername,
        "ts": formattedDate,
        "time": FieldValue.serverTimestamp(),
        "imgUrl": myPicture,
      };

      messageId = randomAlphaNumeric(10); //Le creamos un ID unico

      await DatabaseMethods()
          .addMessage(chatRoomid!, messageId!, messageInfoMap)
          .then((value) {
        // Cerrar el diálogo si aún esta abierto
        if (Navigator.canPop(context)) {
          Navigator.pop(context);
        }

        // Mostrar mensaje de exito
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          backgroundColor: Colors.green,
          content: Text(
            "Audio enviado con éxito",
            style: TextStyle(fontSize: 16),
          ),
        ));
      });
    } catch (e) {
      //Algo fallo? (Puertos o la subida. No importa cae el error aquí)
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        backgroundColor: Colors.red,
        content: Text(
          "Error al subir el audio: $e",
          style: TextStyle(fontSize: 16),
        ),
      ));
    }
  }

  /*            SUBIR UN ARCHIVO DE IMAGEN             */
  Future<void> _uploadImage() async {
    // Si no se selecciona nada
    if (selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        backgroundColor: Colors.red,
        content: Text(
          "Error: No se ha seleccionado ninguna imagen",
          style: TextStyle(fontSize: 20.0),
        ),
      ));
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      backgroundColor: Colors.amber,
      content: Text(
        "Tu imagen se está subiendo",
        style: TextStyle(fontSize: 20.0),
      ),
    ));

    try {
      String imageId = randomAlphaNumeric(10); // Le creamos un ID Unico

      // Obtenemos la referencia de donde lo queremos guardar
      Reference firebaseStorageRef =
          FirebaseStorage.instance.ref().child("chatImages").child(imageId);
      final UploadTask task = firebaseStorageRef
          .putFile(selectedImage!); // Metemos esa imagen en la referencia
      var downloadurl1 =
          await (await task).ref.getDownloadURL(); // obtenemos en la url

      DateTime now = DateTime.now();
      String formattedDate = DateFormat('h:mma').format(now);
      Map<String, dynamic> messageInfoMap = {
        "Data": "Image",
        "message": downloadurl1,
        "sendBy": myUsername,
        "ts": formattedDate,
        "time": FieldValue.serverTimestamp(),
        "imgUrl": myPicture,
      };

      // Y cargamos todo el contenido del mensaje dentro de la base de datos en un chatROOM
      messageId = randomAlphaNumeric(10);
      await DatabaseMethods()
          .addMessage(chatRoomid!, messageId!, messageInfoMap)
          .then((value) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          backgroundColor: Colors.green,
          content: Text(
            "Imagen enviada con éxito",
            style: TextStyle(fontSize: 20.0),
          ),
        ));
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        backgroundColor: Colors.red,
        content: Text(
          "Error al subir la imagen: $e",
          style: TextStyle(fontSize: 20.0),
        ),
      ));
    }
  }

  /*            MOSTRAR LOS MENSAJES                    */
  Widget chatMessageTile(BuildContext context, dynamic data, bool sendByMe) {
    double screenWidth = MediaQuery.of(context).size.width;

    // Verificar si es un mensaje de texto normal
    if (data["Data"] == "Message") {
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
    // Verificar si es un mensaje de tipo imagen
    else if (data["Data"] == "Image") {
      return Row(
        mainAxisAlignment:
            sendByMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          Flexible(
            child: Container(
              padding: EdgeInsets.all(4),
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
                    : Theme.of(context).colorScheme.onSecondary,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.network(
                      data["message"],
                      width: screenWidth * 0.6,
                      fit: BoxFit.cover,
                      // Barra de progreso para cargar imagenes
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Container(
                          width: screenWidth * 0.6,
                          height: screenWidth * 0.6,
                          child: Center(
                            child: CircularProgressIndicator(
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded /
                                      loadingProgress.expectedTotalBytes!
                                  : null,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      "Imagen | ${data["ts"]}",
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: screenWidth * 0.03,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )
        ],
      );
    }
    // Verificar si es un mensaje de tipo audio
    else {
      bool isCurrentlyPlaying =
          _currentlyPlayingUrl == data["message"] && _isPlaying;

      return Row(
        mainAxisAlignment:
            sendByMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          Flexible(
            child: Container(
              padding: EdgeInsets.all(8),
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
                    : Theme.of(context).colorScheme.onSecondary,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Icono responsivo
                  GestureDetector(
                    onTap: () {
                      _playAudio(data["message"]);
                    },
                    child: Icon(
                      isCurrentlyPlaying ? Icons.pause : Icons.play_arrow,
                      color: Colors.white,
                      size: screenWidth * 0.06,
                    ),
                  ),
                  SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isCurrentlyPlaying
                            ? "Pausar Audio"
                            : "Reproducir Audio",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: screenWidth * 0.035,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        data["ts"],
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: screenWidth * 0.03,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          )
        ],
      );
    }
  }

  // Widget encargado de mostrar todos los mensajes que hubo en ese chatRoom mediante un streamBuilder
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
                    return chatMessageTile(
                        context, ds, myUsername == ds["sendBy"]);
                  })
              : Center(child: CircularProgressIndicator());
        });
  }

  // Funcion para agregar un mensaje de lo mas normal (Ya si imagenes, ni audios, solo texto)
  addMessage(bool sendClicked) async {
    if (messagecontroller.text != "") {
      String message = messagecontroller.text;
      messagecontroller.text = "";
      DateTime now = DateTime.now();
      String formattedDate = DateFormat('h:mma').format(now);
      Map<String, dynamic> messageInfoMap = {
        "Data": "Message",
        "message": message,
        "sendBy": myUsername,
        "ts": formattedDate,
        "time": FieldValue.serverTimestamp(),
        "imgUrl": myPicture
      };
      messageId = randomAlphaNumeric(10);

      await DatabaseMethods()
          .addMessage(chatRoomid!, messageId!, messageInfoMap);

      if (sendClicked) {
        message = "";
      }
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
                    GestureDetector(
                      onTap: () {
                        openRecording();
                      },
                      child: Container(
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary,
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Icon(
                          Icons.mic,
                          color: Theme.of(context).colorScheme.onPrimary,
                        ),
                      ),
                    ),
                    SizedBox(width: 10),
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
                            suffixIcon: GestureDetector(
                              onTap: () {
                                getImage();
                              },
                              child: Icon(
                                Icons.attach_file,
                                color: Colors.white,
                              ),
                            ),
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
                          color: Theme.of(context).colorScheme.primary,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          "Envia!",
                          style: TextStyle(
                              color: Theme.of(context).colorScheme.onPrimary),
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
