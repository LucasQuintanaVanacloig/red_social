
import 'package:flutter/material.dart';
import 'package:red_social/paginas/auth/servicios/servicios_auth.dart';

class Burbujamsg extends StatelessWidget {
  final String mensaje;
  final String idAutor;
  final TimeOfDay timestamp;
  const Burbujamsg({super.key, required this.mensaje, required this.idAutor, required this.timestamp});

  @override
  Widget build(BuildContext context) {
    final uidActual = ServiciosAuth().getUsuarioActualUID();

    final esMensajePropio = idAutor == uidActual;

    return Padding(
      padding: const EdgeInsets.only(left: 5, right: 5, top: 10),
      child: Align(
        alignment: esMensajePropio ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          decoration: BoxDecoration(
            color: esMensajePropio
                ? const Color.fromARGB(255, 166, 250, 201)
                : const Color.fromARGB(255, 181, 213, 218),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(mensaje),
          ),
        ),
      ),
    );
  }
}

