import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:red_social/paginas/Configuracion/settings.dart' as miSettings;
import 'package:red_social/paginas/auth/servicios/servicios_auth.dart';
import 'package:red_social/services/servicioPublicacionesAPI.dart';

class Profile extends StatefulWidget {
  final String? userId;

  const Profile({super.key, this.userId});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  String? userId;
  String? nombreUsuario;
  final ServiciosAuth _authService = ServiciosAuth();
  final ServicioPublicacionesAPI _apiService = ServicioPublicacionesAPI();

  File? _imagenPerfil;
  final TextEditingController _nombreController = TextEditingController();
  Future<List<Map<String, dynamic>>>? _publicacionesFuture;

  @override
  void initState() {
    super.initState();
    userId = widget.userId ?? _authService.getUsuarioActualUID();
    _cargarNombreUsuario();
    _cargarPublicaciones();
  }

  void _cargarPublicaciones() {
    _publicacionesFuture = _apiService.cargarPublicaciones(userId ?? "").then((lista) {
      lista.sort((a, b) {
        final fechaA = DateTime.tryParse(a['fecha'] ?? '') ?? DateTime(1970);
        final fechaB = DateTime.tryParse(b['fecha'] ?? '') ?? DateTime(1970);
        return fechaB.compareTo(fechaA);
      });
      return lista;
    });
    setState(() {});
  }

  Future<void> _cargarNombreUsuario() async {
    final nombre = await _authService.obtenerNombreUsuario();
    setState(() {
      nombreUsuario = nombre ?? 'Desconocido';
      _nombreController.text = nombreUsuario!;
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
              style: ElevatedButton.styleFrom(backgroundColor: Colors.deepOrange),
              child: const Text('Guardar cambios'),
              onPressed: _guardarCambiosPerfil,
            ),
          ],
        );
      },
    );
  }

  void _guardarCambiosPerfil() async {
    final nuevoNombre = _nombreController.text.trim();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      if (nuevoNombre.isNotEmpty) {
        await _authService.actualizarNombreUsuario(nuevoNombre);
      }

      if (_imagenPerfil != null) {
        final downloadUrl = await _authService.subirImagenPerfil(_imagenPerfil!);
        await FirebaseFirestore.instance
            .collection('Usuarios')
            .doc(userId)
            .update({'imagenUrl': downloadUrl});
      }

      Navigator.of(context).pop(); // Cierra loading
      Navigator.of(context).pop(); // Cierra modal

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Perfil actualizado correctamente')),
      );
    } catch (e) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al guardar: \$e')),
      );
    }
  }

  Widget _buildStatColumn(String label, String count, VoidCallback onTap) {
    return Column(
      children: [
        Text(count, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
        GestureDetector(
          onTap: onTap,
          child: Text(label, style: const TextStyle(color: Colors.orangeAccent)),
        ),
      ],
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
          nombreUsuario ?? 'Desconocido',
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.white),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const miSettings.Settings())).then((_) {
                _cargarPublicaciones();
              });
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
                  StreamBuilder<DocumentSnapshot>(
                    stream: FirebaseFirestore.instance.collection("Usuarios").doc(userId).snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData || snapshot.data?.data() == null) {
                        return const CircleAvatar(
                          radius: 40,
                          backgroundColor: Colors.white24,
                          child: Icon(Icons.person, size: 40, color: Colors.white),
                        );
                      }
                      final data = snapshot.data!.data() as Map<String, dynamic>;
                      final url = data.containsKey('imagenUrl') ? data['imagenUrl'] : null;
                      return CircleAvatar(
                        radius: 40,
                        backgroundImage: url != null ? NetworkImage(url) : null,
                        backgroundColor: Colors.white24,
                        child: url == null ? const Icon(Icons.person, size: 40, color: Colors.white) : null,
                      );
                    },
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildStatColumn("Publicaciones", "0", () {}),
                        _buildStatColumn("Seguidores", "0", () {}),
                        _buildStatColumn("Seguidos", "0", () {}),
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
                  child: const Text("Editar perfil", style: TextStyle(color: Colors.white70, fontSize: 16)),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: _publicacionesFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text("Error: \${snapshot.error}", style: TextStyle(color: Colors.white)));
                  }
                  final publicaciones = snapshot.data ?? [];
                  if (publicaciones.isEmpty) {
                    return const Center(child: Text("No hay publicaciones", style: TextStyle(color: Colors.white70)));
                  }
                  return GridView.builder(
                    padding: const EdgeInsets.all(8),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 5,
                      mainAxisSpacing: 5,
                    ),
                    itemCount: publicaciones.length,
                    itemBuilder: (context, index) {
                      final path = publicaciones[index]["imagenPath"];
                      return ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.file(
                          File(path),
                          fit: BoxFit.cover,
                        ),
                      );
                    },
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}
