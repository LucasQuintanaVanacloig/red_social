import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:red_social/paginas/Configuracion/settings.dart';
import 'package:red_social/paginas/auth/servicios/servicios_auth.dart';

class Profile extends StatefulWidget {
  final String? userId;

  const Profile({super.key, this.userId});

  @override
  State<Profile> createState() => _ProfileState();
}
// hola 

class _ProfileState extends State<Profile> {
  String? userId;
  String? nomUsuari;
  final ServiciosAuth _authService = ServiciosAuth();

  File? _imagenPerfil;
  final TextEditingController _nombreController = TextEditingController();

  @override
  void initState() {
    super.initState();
    userId = widget.userId ?? _authService.getUsuarioActualUID();
    _cargarNombreUsuario();
  }

  Future<void> _cargarNombreUsuario() async {
    String? nombre = await _authService.obtenerNombreUsuario();
    setState(() {
      nomUsuari = nombre ?? "No encontrado";
      _nombreController.text = nomUsuari!;
    });
  }

  void _mostrarModalEditarPerfil() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Editar perfil'),
          content: SingleChildScrollView(
            child: ListBody(
              children: [
                GestureDetector(
                  onTap: () async {
                    final picker = ImagePicker();
                    final XFile? imagen = await picker.pickImage(source: ImageSource.gallery);
                    if (imagen != null) {
                      setState(() {
                        _imagenPerfil = File(imagen.path);
                      });
                    }
                  },
                  child: CircleAvatar(
                    radius: 40,
                    backgroundImage: _imagenPerfil != null ? FileImage(_imagenPerfil!) : null,
                    child: _imagenPerfil == null ? const Icon(Icons.camera_alt, size: 40) : null,
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _nombreController,
                  decoration: const InputDecoration(
                    labelText: 'Nombre de usuario',
                    hintText: 'Escribe tu nombre...',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepOrange,
              ),
              child: const Text('Guardar cambios'),
              onPressed: () async {
                final nuevoNombre = _nombreController.text.trim();
                if (nuevoNombre.isNotEmpty) {
                  await _authService.actualizarNombreUsuario(nuevoNombre);
                  await _cargarNombreUsuario();
                }
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _showBottomSheet(String title) {
    showModalBottomSheet(
      backgroundColor: Colors.black.withOpacity(0.9),
      context: context,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Text(
                title,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              const Divider(color: Colors.white24),
              Expanded(
                child: ListView.builder(
                  itemCount: 10,
                  itemBuilder: (context, index) {
                    return ListTile(
                      leading: const CircleAvatar(
                        backgroundColor: Colors.deepOrange,
                        child: Icon(Icons.person, color: Colors.white),
                      ),
                      title: Text("Usuario $index", style: const TextStyle(color: Colors.white)),
                      subtitle: const Text("Descripción corta", style: TextStyle(color: Colors.white60)),
                      trailing: ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange.shade600,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text("Seguir"),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Text(
          nomUsuari ?? 'Desconocido',
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const Settings()),
              );
            },
          ),
        ],
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
        child: Column(
          children: [
            const SizedBox(height: 90),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.white24,
                    child: Icon(Icons.person, size: 40, color: Colors.white),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildStatColumn("Publicaciones", "0", () => _showBottomSheet("Publicaciones")),
                        _buildStatColumn("Seguidores", "0", () => _showBottomSheet("Seguidores")),
                        _buildStatColumn("Seguidos", "0", () => _showBottomSheet("Seguidos")),
                      ],
                    ),
                  )
                ],
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: TextButton(
                  onPressed: _mostrarModalEditarPerfil,
                  child: const Text(
                    "Editar perfil",
                    style: TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.all(8),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 5,
                  mainAxisSpacing: 5,
                ),
                itemCount: 9,
                itemBuilder: (context, index) {
                  return Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Center(
                      child: Icon(Icons.add, size: 30, color: Colors.white),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatColumn(String label, String count, VoidCallback onTap) {
    return Column(
      children: [
        Text(
          count,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        GestureDetector(
          onTap: onTap,
          child: Text(label, style: const TextStyle(color: Colors.orangeAccent)),
        ),
      ],
    );
  }
}
