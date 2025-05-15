import 'package:flutter/material.dart';
import 'package:goyolingua/pages/onboarding.dart';
import 'core/theme/theme.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: "GoyoLingua",
        debugShowCheckedModeBanner: false,
        theme: AppTheme.miPropioTema,
        home: const Onboarding());
  }
}
