import 'package:flutter/material.dart';
import 'package:red_social/paginas/Configuracion/config_cuenta.dart';
import 'package:red_social/paginas/Configuracion/config_privacidad.dart';
import 'package:red_social/paginas/Configuracion/config_notificaciones.dart';
import 'package:red_social/paginas/auth/Index.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Settings extends StatefulWidget {
  const Settings({super.key});

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  final int _selectedIndex = 3; // Índice de perfil en BottomNavigationBar

  // Método para cerrar sesión
  Future<void> _logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', false);

    // Redirigir al usuario a la pantalla de login
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const Index()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Configuración"),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context); // Regresar a la página anterior
          },
        ),
      ),
      body: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.person, color: Colors.black),
            title: const Text("Configuración de cuenta"),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ConfigCuenta()),
              );
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.lock, color: Colors.black),
            title: const Text("Privacidad"),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ConfigPrivacidad()),
              );
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.notifications, color: Colors.black),
            title: const Text("Notificaciones"),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ConfigNotificaciones()),
              );
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.exit_to_app, color: Colors.red),
            title: const Text(
              "Cerrar sesión",
              style: TextStyle(color: Colors.red),
            ),
            onTap: () {
              _logout();
            },
          ),
          const Divider(),
        ],
      ),
    );
  }
}
