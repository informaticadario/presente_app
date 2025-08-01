import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'lista_grupos_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    // Timer para redirigir al HomeScreen
    Timer(const Duration(seconds: 4), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => ListaGruposScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo con animación Fade + Pulse
            Animate(
              onPlay: (controller) => controller.repeat(reverse: true),
              effects: [
                ScaleEffect(
                  begin: Offset(1.0, 1.0),
                  end: Offset(1.05, 1.05), // Pequeño pulso
                  duration: 2000.ms, // Movimiento lento y suave
                  curve: Curves.easeInOut, // Transición elegante
                ),
              ],
              child: Image.asset('assets/images/logo.png', width: 120),
            ),

            const SizedBox(height: 30),

            // Título animado
            Animate(
              effects: [
                FadeEffect(duration: 1000.ms, delay: 500.ms),
                SlideEffect(
                  begin: Offset(0, 0.3),
                  end: Offset.zero,
                  duration: 800.ms,
                ),
              ],
              child: const Text(
                'Bienvenido a Presente App',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueAccent,
                  letterSpacing: 1.2,
                ),
              ),
            ),

            const SizedBox(height: 10),

            // Subtítulo animado
            Animate(
              effects: [
                FadeEffect(duration: 1000.ms, delay: 800.ms),
                ScaleEffect(
                  begin: Offset(0.95, 0.95),
                  end: Offset(1.0, 1.0),
                  duration: 500.ms,
                  curve: Curves.easeOut,
                ),
              ],
              child: const Text(
                'Tu herramienta educativa inteligente',
                style: TextStyle(
                  fontSize: 18,
                  fontStyle: FontStyle.italic,
                  color: Colors.black54,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
