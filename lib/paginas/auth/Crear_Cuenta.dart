import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:red_social/componentes/botones.dart';
import 'package:red_social/componentes/custom_appbar.dart';
import 'package:red_social/componentes/input_text.dart';
import 'package:red_social/paginas/auth/login.dart';
import 'package:red_social/paginas/auth/servicios/servicios_auth.dart';

class CrearCuenta extends StatefulWidget {
  const CrearCuenta({super.key});

  @override
  State<CrearCuenta> createState() => _CrearCuentaState();
}

class _CrearCuentaState extends State<CrearCuenta> {
  TextEditingController tecNom = TextEditingController();
  TextEditingController tecCorreo = TextEditingController();
  TextEditingController tecPassw = TextEditingController();
  TextEditingController tecRePassw = TextEditingController();

  bool validarCorreo(String correo) {
    String patron =
        r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$';
    return RegExp(patron).hasMatch(correo);
  }

  void verificarConexionFirestore() async {
    try {
      FirebaseFirestore.instance.settings =
          const Settings(persistenceEnabled: false);
      await FirebaseFirestore.instance
          .collection("TestConexion")
          .doc("check")
          .set({"status": "online", "timestamp": FieldValue.serverTimestamp()});
    } catch (e) {
      print("❌ Firestore error: $e");
    }
  }

  void validarYCrearCuenta() async {
    verificarConexionFirestore();
    String nombre = tecNom.text.trim();
    String correo = tecCorreo.text.trim();
    String passw = tecPassw.text;
    String rePassw = tecRePassw.text;

    if (nombre.isEmpty || correo.isEmpty || passw.isEmpty || rePassw.isEmpty) {
      mostrarMensaje("Todos los campos son obligatorios.");
      return;
    }

    if (!validarCorreo(correo)) {
      mostrarMensaje("Formato de correo inválido.");
      return;
    }

    if (passw.length < 6) {
      mostrarMensaje("Contraseña mínima de 6 caracteres.");
      return;
    }

    if (passw != rePassw) {
      mostrarMensaje("Las contraseñas no coinciden.");
      return;
    }

    String? resultado =
        await ServiciosAuth().registrarUsuario(correo, passw, nombre);

    if (resultado == null) {
      mostrarMensaje("Cuenta creada exitosamente!", esExito: true);
      Future.delayed(const Duration(seconds: 2), () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const Login()),
        );
      });
    } else {
      mostrarMensaje(resultado);
    }
  }

  void mostrarMensaje(String mensaje, {bool esExito = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje, style: const TextStyle(color: Colors.white)),
        backgroundColor: esExito ? Colors.green : Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFFFD5E53),
              Color(0xFFFD754D),
              Color(0xFFFE8714),
              Color(0xFFFE6900),
              Color(0xFFEF5200),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                const SizedBox(height: 30),
                const Icon(Icons.wb_sunny, size: 64, color: Colors.white),
                const SizedBox(height: 12),
                const Text(
                  "Sunset Vibes",
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 1.5,
                    fontFamily: 'Sansita',
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  "¡Crea tu cuenta y únete a la vibra!",
                  style: TextStyle(color: Colors.white70, fontSize: 16),
                ),
                const SizedBox(height: 30),
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(color: Colors.white24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      InputText(
                        textEtiqueta: "Nombre",
                        textHint: "Tu nombre completo",
                        tecInput: tecNom,
                      ),
                      const SizedBox(height: 16),
                      InputText(
                        textEtiqueta: "Correo electrónico",
                        textHint: "ejemplo@correo.com",
                        tecInput: tecCorreo,
                      ),
                      const SizedBox(height: 16),
                      InputText(
                        textEtiqueta: "Contraseña",
                        textHint: "Mínimo 6 caracteres",
                        tecInput: tecPassw,
                        passwd: true,
                      ),
                      const SizedBox(height: 16),
                      InputText(
                        textEtiqueta: "Repite la contraseña",
                        textHint: "Confirma tu contraseña",
                        tecInput: tecRePassw,
                        passwd: true,
                      ),
                      const SizedBox(height: 30),
                      ElevatedButton(
                        onPressed: validarYCrearCuenta,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFEF5200),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 40, vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                          elevation: 6,
                        ),
                        child: const Text(
                          "Crear Cuenta",
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextButton(
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) => const Login()),
                          );
                        },
                        child: const Text(
                          "¿Ya tienes cuenta? Inicia sesión",
                          style: TextStyle(color: Colors.white70),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
