import 'package:flutter/material.dart';
import 'package:goyolingua/core/Services/auth.dart';

class Onboarding extends StatefulWidget {
  const Onboarding({super.key});

  @override
  State<Onboarding> createState() => _OnboardingState();
}

class _OnboardingState extends State<Onboarding> {
  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Imagen ocupa la mitad superior de la pantalla
            SizedBox(
              height: screenHeight * 0.65,
              width: screenWidth,
              child: Image.asset(
                "assets/img/GoyoLingua.png",
                fit: BoxFit.cover,
                alignment: const Alignment(0, 0.40),
              ),
            ),

            // Contenido inferior
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 20.0, vertical: 30.0),
                child: GestureDetector(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        "Disfruta el aprender inglés como nunca antes, querido universitario",
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              fontSize: 20,
                            ),
                      ),
                      const SizedBox(height: 40),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: () {
                            AuthMethods().signInWithGoogle(context);
                          },
                          child: const Text("¡Inicia sesión con Google!"),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
