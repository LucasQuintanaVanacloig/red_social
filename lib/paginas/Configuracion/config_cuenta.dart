import 'package:flutter/material.dart';
import 'package:red_social/paginas/Configuracion/config_cuenta_editar.dart';
import 'package:red_social/paginas/auth/Index.dart';

class ConfigCuenta extends StatelessWidget {
  const ConfigCuenta({super.key});

  // Método para mostrar la confirmación de eliminación de cuenta
  void _confirmarBorrado(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Confirmar eliminación"),
          content: const Text("¿Estás seguro de que deseas borrar tu cuenta? Esta acción no se puede deshacer."),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Cerrar diálogo
              },
              child: const Text("Cancelar", style: TextStyle(color: Colors.black)),
            ),
            TextButton(
              onPressed: () {
                // Aquí iría la lógica para eliminar la cuenta
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const Index()), // Redirigir a pantalla inicial
                );
              },
              child: const Text("Borrar", style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Configuración de cuenta"),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context); // Regresar a la pantalla anterior
          },
        ),
      ),
      body: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.swap_horiz, color: Colors.black),
            title: const Text("Cambiar cuenta"),
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const Index()), // Simula el cambio de cuenta
              );
            },
          ),
       
          const Divider(),
          ListTile(
            leading: const Icon(Icons.delete, color: Colors.red),
            title: const Text(
              "Borrar cuenta",
              style: TextStyle(color: Colors.red),
            ),
            onTap: () {
              _confirmarBorrado(context);
            },
          ),
          const Divider(),
        ],
      ),
    );
  }
}
