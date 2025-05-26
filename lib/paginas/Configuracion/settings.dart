import 'package:flutter/material.dart';
import 'package:red_social/paginas/Configuracion/config_cuenta_editar.dart';
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
  final int _selectedIndex = 3;

  Future<void> _logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', false);
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const Index()),
    );
  }

  Widget _buildSettingsOption(IconData icon, String title, VoidCallback onTap, {Color? iconColor, Color? textColor}) {
    return Column(
      children: [
        ListTile(
          leading: Icon(icon, color: iconColor ?? Colors.white),
          title: Text(
            title,
            style: TextStyle(color: textColor ?? Colors.white, fontSize: 16),
          ),
          onTap: onTap,
        ),
        const Divider(color: Colors.white24, thickness: 0.5),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text("Configuración", style: TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFFFD5E53),
              Color(0xFFFD754D),
              Color(0xFFFE8714),
              Color(0xFFFE6900),
              Color(0xFF1A1A40),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
             
              _buildSettingsOption(
                Icons.lock,
                "Privacidad",
                () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ConfigPrivacidad()),
                ),
              ),
              _buildSettingsOption(
                Icons.notifications,
                "Notificaciones",
                () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ConfigNotificaciones()),
                ),
              ),
              _buildSettingsOption(
                Icons.exit_to_app,
                "Cerrar sesión",
                _logout,
                iconColor: const Color.fromARGB(255, 185, 0, 0),
                textColor: const Color.fromARGB(255, 152, 0, 0),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
