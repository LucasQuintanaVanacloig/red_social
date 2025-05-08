import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ConfigPrivacidad extends StatefulWidget {
  const ConfigPrivacidad({super.key});

  @override
  State<ConfigPrivacidad> createState() => _ConfigPrivacidadState();
}

class _ConfigPrivacidadState extends State<ConfigPrivacidad> {
  String _tipoCuenta = "privada"; // Estado inicial

  @override
  void initState() {
    super.initState();
    _cargarPreferencias();
  }

  // Cargar la preferencia guardada
  Future<void> _cargarPreferencias() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _tipoCuenta = prefs.getString('tipo_cuenta') ?? "privada";
    });
  }

  // Guardar preferencia cuando cambia la selección
  Future<void> _guardarPreferencia(String value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('tipo_cuenta', value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Privacidad"),
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
          const ListTile(
            title: Text(
              "Tipo de cuenta",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          RadioListTile<String>(
            title: const Text("Cuenta pública"),
            value: "publica",
            groupValue: _tipoCuenta,
            onChanged: (String? value) {
              setState(() {
                _tipoCuenta = value!;
              });
              _guardarPreferencia(value!);
            },
            activeColor: Colors.blue,
          ),
          const Divider(),
          RadioListTile<String>(
            title: const Text("Cuenta privada"),
            value: "privada",
            groupValue: _tipoCuenta,
            onChanged: (String? value) {
              setState(() {
                _tipoCuenta = value!;
              });
              _guardarPreferencia(value!);
            },
            activeColor: Colors.blue,
          ),
          const Divider(),
        ],
      ),
    );
  }
}
