import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:red_social/componentes/bottom_nav.dart';
import 'package:red_social/paginas/auth/servicios/servicioPublicaciones.dart';

class CreatePage extends StatefulWidget {
  const CreatePage({super.key});

  @override
  State<CreatePage> createState() => _CreatePageState();
}

class _CreatePageState extends State<CreatePage> {
  File? _image;
  final TextEditingController _descripcionController = TextEditingController();
  final ServicioPublicaciones _servicioPublicaciones = ServicioPublicaciones();
  bool _cargando = false;

  Future<void> _pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _image = File(picked.path);
      });
    }
  }

  Future<void> _publicar() async {
    if (_image == null || _descripcionController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Selecciona una imagen y escribe una descripción")),
      );
      return;
    }

    setState(() => _cargando = true);
    try {
      final url = await _servicioPublicaciones.subirImagen(_image!);
      await _servicioPublicaciones.crearPublicacion(
        descripcion: _descripcionController.text.trim(),
        imagenPath: url,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("✅ Publicación creada exitosamente")),
      );
      setState(() {
        _image = null;
        _descripcionController.clear();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ Error al publicar: $e")),
      );
    } finally {
      setState(() => _cargando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: const Color(0xFF1A1A40),
        appBar: AppBar(
          title: const Text("Crear publicación"),
          centerTitle: true,
          backgroundColor: const Color(0xFF2C1A1D),
          elevation: 0,
        ),
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFFFFA17F),
                Color(0xFFEF5E4E),
                Color(0xFF1A1A40),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: ListView(
              children: [
                // Imagen seleccionada
                Container(
                  height: 220,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: Colors.black.withOpacity(0.1),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: _image != null
                        ? Image.file(_image!, fit: BoxFit.cover)
                        : const Center(
                            child: Text(
                              "No hay imagen seleccionada",
                              style: TextStyle(color: Colors.white70),
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 20),

                // Campo de descripción
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: TextField(
                    controller: _descripcionController,
                    maxLines: 4,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      hintText: "Escribe una descripción...",
                      hintStyle: TextStyle(color: Colors.white60),
                      border: InputBorder.none,
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                // Botón seleccionar imagen
                ElevatedButton.icon(
                  onPressed: _pickImage,
                  icon: const Icon(Icons.image_outlined),
                  label: const Text("Seleccionar imagen"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFEF5E4E),
                    foregroundColor: Colors.white,
                    elevation: 2,
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                ),

                const SizedBox(height: 16),

                // Botón publicar
                ElevatedButton.icon(
                  onPressed: _cargando ? null : _publicar,
                  icon: const Icon(Icons.send_rounded),
                  label: _cargando
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text("Publicar"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFD5E53),
                    foregroundColor: Colors.white,
                    elevation: 2,
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                ),
              ],
            ),
          ),
        ),
        bottomNavigationBar: const BottomNav(currentIndex: 2),
      ),
    );
  }
}
