import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ConfigNotificaciones extends StatefulWidget {
  const ConfigNotificaciones({super.key});

  @override
  State<ConfigNotificaciones> createState() => _ConfigNotificacionesState();
}

class _ConfigNotificacionesState extends State<ConfigNotificaciones> {
  bool _notificacionesActivadas = false;
  bool _sonidoActivado = false;

  @override
  void initState() {
    super.initState();
    _cargarPreferencias();
  }

  // Cargar el estado guardado de los switches
  Future<void> _cargarPreferencias() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _notificacionesActivadas = prefs.getBool('notificaciones') ?? false;
      _sonidoActivado = prefs.getBool('sonido_notificaciones') ?? false;
    });
  }

  // Guardar preferencias cuando cambian
  Future<void> _guardarPreferencia(String key, bool value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Notificaciones"),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Column(
        children: [
          SwitchListTile(
            title: const Text("Activar notificaciones"),
            value: _notificacionesActivadas,
            onChanged: (bool value) {
              setState(() {
                _notificacionesActivadas = value;
              });
              _guardarPreferencia('notificaciones', value);
            },
            activeColor: Colors.blue,
          ),
          const Divider(),
          SwitchListTile(
            title: const Text("Sonido de notificaciones"),
            value: _sonidoActivado,
            onChanged: (bool value) {
              setState(() {
                _sonidoActivado = value;
              });
              _guardarPreferencia('sonido_notificaciones', value);
            },
            activeColor: Colors.blue,
          ),
          const Divider(),
        ],
      ),
    );
  }
}
