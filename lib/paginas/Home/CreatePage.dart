import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:red_social/paginas/auth/servicios/servicios_auth.dart';
import 'package:red_social/services/servicioPublicacionesAPI.dart';
import 'package:red_social/services/servicioImagenesAPI.dart';

class CreatePage extends StatefulWidget {
  /// Callback que se dispara tras crear correctamente la publicación
  final VoidCallback onPublish;
  const CreatePage({super.key, required this.onPublish});

  @override
  _CreatePageState createState() => _CreatePageState();
}

class _CreatePageState extends State<CreatePage> {
  File? _image;
  final _descripcionController = TextEditingController();
  final _apiService            = ServicioPublicacionesAPI();
  final _imgService            = ServicioImagenesAPI();
  final _authService           = ServiciosAuth();
  bool _cargando               = false;

  Future<void> _pickImage() async {
    final f = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (f != null) setState(() => _image = File(f.path));
  }

  Future<void> _publicar() async {
    if (_image == null || _descripcionController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Selecciona imagen y descripción")),
      );
      return;
    }
    setState(() => _cargando = true);
    bool creado = false;
    try {
      final uid     = _authService.getUsuarioActualUID();
      if (uid == null) throw Exception("Usuario no autenticado");

      final urlImg  = await _imgService.uploadImage(_image!);
      final usuario = await _authService.obtenerNombreUsuario() ?? '';
      final email   = _authService.getUsuarioEmail()        ?? '';
      final perfil  = await _authService.obtenerImagenPerfil() ?? '';
      final desc    = _descripcionController.text.trim();

      await _apiService.crearPublicacion(
        uid:          uid,
        usuario:      usuario,
        email:        email,
        descripcion:  desc,
        imagenPost:   urlImg,
        imagenPerfil: perfil,
      );

      creado = true;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("✅ Publicación creada")),
      );
      // Dispara el callback de MainScreen para refrescar Home/Profile
      widget.onPublish();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ Error: $e")),
      );
    } finally {
      if (!mounted) return;
      setState(() => _cargando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ));

    return Container(
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
        top: false,
        child: Column(
          children: [
            const SizedBox(height: 24),
            Row(
              children: [
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    "Nueva publicación",
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 56),
              ],
            ),
            const SizedBox(height: 20),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    Container(
                      height: 250,
                      decoration: BoxDecoration(
                        color: Colors.black26,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.white24),
                      ),
                      child: _image != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: Image.file(_image!, fit: BoxFit.cover),
                            )
                          : const Center(
                              child: Text(
                                "No hay imagen",
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
                        fillColor: Colors.black26,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Colors.white24),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      onPressed: _pickImage,
                      icon: const Icon(Icons.image, color: Colors.white),
                      label: const Text("Seleccionar Imagen"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orangeAccent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      onPressed: _cargando ? null : _publicar,
                      icon: _cargando
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 2,
                              ),
                            )
                          : const Icon(Icons.upload, color: Colors.white),
                      label: Text(
                        _cargando ? "Publicando..." : "Publicar",
                        style: const TextStyle(color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepOrangeAccent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
