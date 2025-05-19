import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:red_social/paginas/auth/servicios/servicios_auth.dart';
import 'package:red_social/services/servicioPublicacionesAPI.dart';

class CreatePage extends StatefulWidget {
  const CreatePage({super.key});

  @override
  _CreatePageState createState() => _CreatePageState();
}

class _CreatePageState extends State<CreatePage> {
  File? _image;
  final TextEditingController _descripcionController = TextEditingController();
  final ServicioPublicacionesAPI _apiService = ServicioPublicacionesAPI();
  final ServiciosAuth _authService = ServiciosAuth();
  bool _cargando = false;

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
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
      final uid = _authService.getUsuarioActualUID();
      if (uid == null) throw Exception("Usuario no autenticado");

      final imagenPath = _image!.path;
      final descripcion = _descripcionController.text.trim();
      final fecha = DateTime.now().toUtc().toIso8601String();

      await _apiService.crearPublicacion(
        uid: uid,
        descripcion: descripcion,
        imagenPath: imagenPath,
        fecha: fecha,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("✅ Publicación creada exitosamente")),
      );
      setState(() {
        _image = null;
        _descripcionController.clear();
      });
    } catch (e, stack) {
      print("Error al crear publicación: $e");
      print("StackTrace: $stack");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ Error al crear publicación: $e")),
      );
    } finally {
      setState(() => _cargando = false);
    }
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
              Color(0xFF1A1A40),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: IntrinsicHeight(
                    child: Column(
                      children: [
                        AppBar(
                          backgroundColor: Colors.transparent,
                          elevation: 0,
                          title: const Text(
                            "Nueva publicación",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1,
                            ),
                          ),
                          centerTitle: true,
                          automaticallyImplyLeading: false,
                        ),
                        const SizedBox(height: 20),
                        Container(
                          height: 250,
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.white24),
                          ),
                          child: _image != null
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(16),
                                  child: Image.file(
                                    _image!,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                  ),
                                )
                              : const Center(
                                  child: Text(
                                    "No hay imagen seleccionada",
                                    style: TextStyle(color: Colors.white70),
                                  ),
                                ),
                        ),
                        const SizedBox(height: 20),
                        TextField(
                          controller: _descripcionController,
                          maxLines: 4,
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            labelText: "Descripción",
                            labelStyle: const TextStyle(color: Colors.white70),
                            filled: true,
                            fillColor: Colors.black.withOpacity(0.2),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: Colors.white24),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: Colors.white24),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: Colors.orangeAccent),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: _pickImage,
                                icon: const Icon(Icons.image, color: Colors.white),
                                label: const Text("Seleccionar Imagen"),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.orangeAccent.withOpacity(0.8),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: _cargando ? null : _publicar,
                                icon: _cargando
                                    ? const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : const Icon(Icons.upload, color: Colors.white),
                                label: _cargando
                                    ? const Text("Publicando...", style: TextStyle(color: Colors.white))
                                    : const Text("Publicar"),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.deepOrangeAccent.withOpacity(0.9),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
