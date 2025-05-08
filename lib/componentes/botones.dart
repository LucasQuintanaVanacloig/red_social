  import 'package:flutter/material.dart';

class Botones extends StatefulWidget {
  final String textBoton;
  final Function() accionBoton;
  final double? limite_width;
  final double? limite_right;

  const Botones({super.key, required this.textBoton, required this.accionBoton, this.limite_width, this.limite_right});

  @override
  _BotonesState createState() => _BotonesState();
}

class _BotonesState extends State<Botones> {
  bool isHovering = false; // Para detectar el hover

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => isHovering = true), // Activa hover
      onExit: (_) => setState(() => isHovering = false), // Desactiva hover
      child: InkWell(
        onTap: widget.accionBoton,
        borderRadius: BorderRadius.circular(20),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200), // Animación suave
          width: widget.limite_width ?? 180, // Si no se define, usa 200
          height: widget.limite_right ?? 45, // Si no se define, usa 50
          decoration: BoxDecoration(
            color: isHovering ? Colors.grey[300] : Colors.white, // Cambio de color al hacer hover
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white, width: 2), // Borde blanco
            boxShadow: [
              BoxShadow(
                color: isHovering ? Colors.white54 : Colors.grey[600]!, // Sombra dinámica
                blurRadius: isHovering ? 4 : 5,
                spreadRadius: isHovering ? 2 : 1,
                offset: const Offset(0, 0),
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 25),
          child: Center(
            child: Text(
              widget.textBoton,
              style: TextStyle(
                color: Colors.black87, // Texto oscuro para contrastar con el botón blanco
                fontSize: isHovering ? 18 : 18,
                fontWeight: isHovering ? FontWeight.w900 : FontWeight.w500,
                letterSpacing: 1.5,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
