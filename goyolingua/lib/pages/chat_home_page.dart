import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:goyolingua/core/Services/chat_utils.dart';
import 'package:goyolingua/core/Services/database.dart';
import 'package:goyolingua/core/Services/shared_pref.dart';
import 'package:goyolingua/core/widgets/widgetsHomePage/card.dart';
import 'package:goyolingua/core/widgets/widgetsHomePage/student_list.dart';
import 'package:goyolingua/core/widgets/widgetsHomePage/teacher_list.dart';
import 'package:goyolingua/pages/profile.dart';

class ChatHomePage extends StatefulWidget {
  const ChatHomePage({super.key});

  @override
  State<ChatHomePage> createState() => _ChatHomePageState();
}

class _ChatHomePageState extends State<ChatHomePage> {
  Stream<QuerySnapshot>? chatTeacherStream;
  Stream<QuerySnapshot>? chatStudentStream;
  String? myUsername, myName, myEmail, myPicture, chatRoomid, messageId;
  bool? amITeacher;
  bool isLoading =
      true; // Agregamos una bandera para controlar la carga inicial

  TextEditingController searchcontroller = TextEditingController();
  bool search = false;
  var queryResultSet = [];
  var tempSearchStore = [];

  getthesharedpref() async {
    try {
      myUsername = await SharedpreferenceHelper.getUserUserName();
      myName = await SharedpreferenceHelper.getUserDisplayName();
      myEmail = await SharedpreferenceHelper.getUserEmail();
      myPicture = await SharedpreferenceHelper.getUserImage();
      amITeacher = await SharedpreferenceHelper.getUserEresMaestro() ??
          false; // Valor por defecto

      await getTeachersStream(); // Esperamos a que se completen los streams

      setState(() {
        isLoading = false; // Marcamos que la carga ha terminado
      });
    } catch (e) {
      setState(() {
        amITeacher = false; // Valor por defecto en caso de error
        isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    getthesharedpref(); // Iniciamos la carga de datos
  }

  Future<void> getTeachersStream() async {
    chatTeacherStream = await DatabaseMethods().getAllTeachers();
    chatStudentStream = await DatabaseMethods().getAllStudents();
  }

  void initiateSearch(String value) {
    if (value.isEmpty) {
      setState(() {
        search = false;
        queryResultSet = [];
        tempSearchStore = [];
      });
      return;
    }

    setState(() {
      search = true;
    });

    if (queryResultSet.isEmpty && value.length == 1) {
      DatabaseMethods().Search(value).then((QuerySnapshot docs) {
        if (mounted) {
          // Verificar si el widget aún está montado
          setState(() {
            queryResultSet =
                docs.docs.map((e) => e.data() as Map<String, dynamic>).toList();

            tempSearchStore = queryResultSet;
          });
        }
      });
    } else {
      setState(() {
        tempSearchStore = queryResultSet
            .where((element) => element['username']
                .toString()
                .toLowerCase()
                .startsWith(value.toLowerCase()))
            .toList();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 44, 44, 44),
      body: isLoading
          ? const Center(
              child:
                  CircularProgressIndicator()) // Mostrar indicador de carga mientras se inicializa
          : Column(
              children: [
                /*                                                      ZONA SUPERIOR (Zona del header)                                                  */
                Container(
                  margin:
                      const EdgeInsets.only(top: 20.0, left: 20.0, right: 20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          //Logo de GoyoLingua
                          Image.asset(
                            "assets/img/GoyoSaludo.png",
                            height: screenHeight * 0.12,
                            width: screenWidth * 0.1,
                            fit: BoxFit.contain,
                          ),
                          const SizedBox(width: 10.0),
                          Text(
                            "Hola! Listo para conversar?",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: screenWidth * 0.04,
                                fontWeight: FontWeight.w600),
                          ),
                          // El Spacer sirve como un justify content between
                          const Spacer(),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => ProfilePage()),
                              );
                            },
                            child: Container(
                              padding: const EdgeInsets.all(5),
                              margin:
                                  EdgeInsets.only(right: screenWidth * 0.02),
                              decoration: BoxDecoration(
                                  color: Theme.of(context).colorScheme.primary,
                                  borderRadius: BorderRadius.circular(50)),
                              child: Icon(
                                Icons.person,
                                color: Theme.of(context).colorScheme.onPrimary,
                                size: screenWidth * 0.07,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Text(
                        myName ??
                            "Usuario", // Valor por defecto si myName es null
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: screenWidth * 0.04,
                            fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 10.0),
                      Text(
                        "Bienvenido a nuestro chat de GoyoLingua!",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: const Color.fromARGB(207, 255, 255, 255),
                            fontSize: screenWidth * 0.04,
                            fontWeight: FontWeight.w400),
                      ),
                      const SizedBox(height: 20.0),
                    ],
                  ),
                ),
                /* ZONA INFERIOR */
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.only(left: 20.0, right: 20.0),
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      color: Color.fromARGB(255, 61, 61, 61),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(5),
                        topRight: Radius.circular(5),
                      ),
                    ),
                    child: Column(
                      children: [
                        const SizedBox(height: 30.0),
                        // Barra de busqueda
                        Container(
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary,
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: TextField(
                            controller: searchcontroller,
                            onChanged: (value) {
                              initiateSearch(value.toUpperCase());
                            },
                            decoration: InputDecoration(
                              fillColor:
                                  const Color.fromARGB(218, 252, 149, 64),
                              hintText: "Busca a alguien para practicar",
                              prefixIcon: const Icon(
                                Icons.search,
                                color: Color.fromARGB(255, 0, 0, 0),
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide.none,
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide.none,
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                  vertical: 14, horizontal: 20),
                            ),
                            cursorRadius: const Radius.circular(10),
                          ),
                        ),

                        const SizedBox(height: 20),
                        /* RENDERIZADO CONDICIONAL */
                        search
                            ? ListView(
                                //Parte de cuando se esta realizando una busqueda
                                padding:
                                    const EdgeInsets.only(left: 10, right: 10),
                                primary: false,
                                shrinkWrap: true,
                                children:
                                    tempSearchStore.map<Widget>((element) {
                                  return PersonalCard(
                                    userData: element,
                                    myUsername: myUsername,
                                    getChatRoomIdbyUsername:
                                        ChatUtils.getChatRoomIdByUsername,
                                  );
                                }).toList(),
                              )
                            : amITeacher == true
                                ? StudentsList(
                                    StudentsStream: chatStudentStream,
                                    myUsername: myUsername,
                                    getChatRoomIdbyUsername:
                                        ChatUtils.getChatRoomIdByUsername)
                                : TeachersList(
                                    teachersStream: chatTeacherStream,
                                    myUsername: myUsername,
                                    getChatRoomIdbyUsername:
                                        ChatUtils.getChatRoomIdByUsername,
                                  )
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
