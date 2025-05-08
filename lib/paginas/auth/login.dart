import 'package:flutter/material.dart';
import 'package:red_social/paginas/auth/servicios/servicios_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:red_social/componentes/botones.dart';
import 'package:red_social/componentes/custom_appbar.dart';
import 'package:red_social/componentes/input_text.dart';
import 'package:red_social/componentes/main_screen.dart';

class Login extends StatelessWidget {
  const Login({super.key});

  Future<void> _login(BuildContext context, String email, String password) async {
    final authService = ServiciosAuth();
    String? error = await authService.iniciarSesion(email, password);

    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error)),
      );
      return;
    }

    String? nombre = await authService.obtenerNombreUsuario();

    if (nombre != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("El usuario $nombre se ha logeado correctamente")),
      );
    }

    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', true);

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const MainScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    TextEditingController tecCorreo = TextEditingController();
    TextEditingController tecPassw = TextEditingController();

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
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 40),
                const Icon(Icons.wb_sunny, size: 72, color: Colors.white),
                const SizedBox(height: 10),
                const Text(
                  "Sunset Vibes",
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 1.5,
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
                  margin: const EdgeInsets.symmetric(horizontal: 24),
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
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      InputText(
                        textEtiqueta: "Correo electrónico",
                        tecInput: tecCorreo,
                        textHint: "ejemplo@correo.com",
                      ),
                      const SizedBox(height: 20),
                      InputText(
                        textEtiqueta: "Contraseña",
                        tecInput: tecPassw,
                        textHint: "Introduce la contraseña",
                        passwd: true,
                      ),
                      const SizedBox(height: 30),
                      Center(
                        child: ElevatedButton(
                          onPressed: () => _login(context, tecCorreo.text, tecPassw.text),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFFEF5200), // Persimmon
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24),
                            ),
                            elevation: 6,
                          ),
                          child: const Text(
                            "Iniciar sesión",
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      const SizedBox(height: 15),
                      Center(
                        child: TextButton(
                          onPressed: () {},
                          child: const Text(
                            "¿Olvidaste tu contraseña?",
                            style: TextStyle(color: Colors.white70),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
