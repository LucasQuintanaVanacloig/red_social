import 'package:flutter/material.dart';
import 'package:red_social/componentes/botones.dart';
import 'package:red_social/paginas/auth/Crear_Cuenta.dart';
import 'package:red_social/paginas/auth/login.dart';

void main() {
  runApp(const Index());
}

class Index extends StatelessWidget {
  const Index({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: LoginScreen(),
    );
  }
}

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFFFD5E53), // Sunset Orange
              Color(0xFFFD754D), // Outrageous Orange
              Color(0xFFFE8714), // Beer
              Color(0xFFFE6900), // Safety Orange
              Color(0xFFEF5200), // Persimmon
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.wb_sunny, size: 72, color: Colors.white),
                      const SizedBox(height: 10),
                      const Text(
                        "Sunset Vibes",
                        style: TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 1.3,
                          fontFamily: 'Sansita',
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        "Siente el atardecer, conecta con el mundo.",
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 16,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                      const SizedBox(height: 40),
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 40),
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(28),
                          border: Border.all(color: Colors.white24),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 18,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => const CrearCuenta()),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Color(0xFFEF5200),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(24),
                                ),
                              ),
                              child: const Text("Crear cuenta", style: TextStyle(fontSize: 16)),
                            ),
                            const SizedBox(height: 20),
                            ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => const Login()),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Color(0xFFEF5200),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(24),
                                ),
                              ),
                              child: const Text("Iniciar sesión", style: TextStyle(fontSize: 16)),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SunsetFooter(),
          ],
        ),
      ),
    );
  }
}

// ==============================
// FOOTER COMPONENT
// ==============================

class SunsetFooter extends StatelessWidget {
  const SunsetFooter({super.key});

  @override
  Widget build(BuildContext context) {
    final textStyle = TextStyle(color: Colors.white70, fontSize: 12);

    return Container(
      color: Colors.transparent,
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      child: Column(
        children: [
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 12,
            runSpacing: 8,
            children: const [
              FooterLink("Información"),
              FooterLink("Blog"),
              FooterLink("Equipo"),
              FooterLink("Ayuda"),
              FooterLink("API"),
              FooterLink("Privacidad"),
              FooterLink("Condiciones"),
              FooterLink("Ubicaciones"),
              FooterLink("Soporte técnico"),
              FooterLink("Verificación"),
              FooterLink("Ceroca Pro"),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            "Español  •  © 2025 Ceroca — Desarrollado por Lucas & Jheremy",
            style: textStyle,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class FooterLink extends StatelessWidget {
  final String label;
  const FooterLink(this.label, {super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: const TextStyle(
        color: Colors.white60,
        fontSize: 12,
        decoration: TextDecoration.underline,
        decorationStyle: TextDecorationStyle.dotted,
      ),
    );
  }
}
