
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:red_social/paginas/auth/servicios/servicioPublicaciones.dart';

class CreatePage extends StatefulWidget {
  const CreatePage({super.key});

  @override
  _CreatePageState createState() => _CreatePageState();
}

class _CreatePageState extends State<CreatePage> {
  File? _image;
  final TextEditingController _descripcionController = TextEditingController();
  final ServicioPublicaciones _servicioPublicaciones = ServicioPublicaciones();
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
      final urlImagen = await _servicioPublicaciones.subirImagen(_image!);
      await _servicioPublicaciones.crearPublicacion(
        descripcion: _descripcionController.text.trim(),
        imagenPath: urlImagen,
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
        SnackBar(content: Text("❌ Error al crear publicación: $e")),
      );
    } finally {
      setState(() => _cargando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Crear publicación"),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _image != null
                ? Image.file(_image!, height: 250)
                : Container(
                    height: 250,
                    color: Colors.grey[300],
                    alignment: Alignment.center,
                    child: const Text("No hay imagen seleccionada"),
                  ),
            const SizedBox(height: 16),
            TextField(
              controller: _descripcionController,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: "Descripción",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _pickImage,
              icon: const Icon(Icons.image),
              label: const Text("Seleccionar Imagen"),
            ),
            const SizedBox(height: 10),
            ElevatedButton.icon(
              onPressed: _cargando ? null : _publicar,
              icon: const Icon(Icons.upload),
              label: _cargando
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Text("Publicar"),
            ),
          ],
        ),
      ),
    );
  }
}
