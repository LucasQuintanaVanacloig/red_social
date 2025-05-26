import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:red_social/paginas/Configuracion/settings.dart' as miSettings;
import 'package:red_social/paginas/auth/servicios/servicios_auth.dart';
import 'package:red_social/services/servicioPublicacionesAPI.dart';

class Profile extends StatefulWidget {
  const Profile({Key? key, this.userId}) : super(key: key);
  final String? userId;

  @override
  ProfileState createState() => ProfileState();  // público
}

class ProfileState extends State<Profile> {
  String? userId;
  String? nombreUsuario;
  final _authService = ServiciosAuth();
  final _apiService  = ServicioPublicacionesAPI();

  File? _imagenPerfil;
  final _nombreController = TextEditingController();
  Future<List<Map<String, dynamic>>>? _publicacionesFuture;

  @override
  void initState() {
    super.initState();
    userId = widget.userId ?? _authService.getUsuarioActualUID();
    _loadUserName();
    refreshPosts();  // inicia carga
  }

  /// método público que invoca la recarga de publicaciones
  void refreshPosts() {
    _publicacionesFuture = _apiService
        .cargarPublicaciones(userId ?? "")
        .then((lista) {
          lista.sort((a, b) {
            final fa = DateTime.tryParse(a['fecha_creacion'] ?? '') ?? DateTime(0);
            final fb = DateTime.tryParse(b['fecha_creacion'] ?? '') ?? DateTime(0);
            return fb.compareTo(fa);
          });
          return lista;
        });
    setState(() {});
  }

  Future<void> _loadUserName() async {
    final nombre = await _authService.obtenerNombreUsuario();
    setState(() {
      nombreUsuario      = nombre ?? 'Desconocido';
      _nombreController.text = nombreUsuario!;
    });
  }

  void _mostrarModalEditarPerfil() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Editar perfil'),
        content: SingleChildScrollView(
          child: ListBody(
            children: [
              GestureDetector(
                onTap: () async {
                  final picker = ImagePicker();
                  final XFile? imagen = await picker.pickImage(source: ImageSource.gallery);
                  if (imagen != null) {
                    setState(() => _imagenPerfil = File(imagen.path));
                  }
                },
                child: CircleAvatar(
                  radius: 40,
                  backgroundImage: _imagenPerfil != null
                      ? FileImage(_imagenPerfil!)
                      : null,
                  child: _imagenPerfil == null
                      ? const Icon(Icons.camera_alt, size: 40)
                      : null,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _nombreController,
                decoration: const InputDecoration(
                  labelText: 'Nombre de usuario',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(child: const Text('Cancelar'), onPressed: () => Navigator.pop(context)),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.deepOrange),
            child: const Text('Guardar cambios'),
            onPressed: _guardarCambiosPerfil,
          ),
        ],
      ),
    );
  }

  Future<void> _guardarCambiosPerfil() async {
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
        final url = await _authService.subirImagenPerfil(_imagenPerfil!);
        await FirebaseFirestore.instance
            .collection('Usuarios')
            .doc(userId)
            .update({'imagenUrl': url});
      }
      Navigator.pop(context); // quita loader
      Navigator.pop(context); // quita modal
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Perfil actualizado correctamente')),
      );
    } catch (e) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al guardar: $e')),
      );
    }
  }

  Widget _buildStatColumn(String label, String count, VoidCallback onTap) {
    return Column(
      children: [
        Text(count, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
        GestureDetector(onTap: onTap, child: Text(label, style: const TextStyle(color: Colors.orangeAccent))),
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
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.white),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const miSettings.Settings()))
                  .then((_) => refreshPosts());
            },
          )
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
                builder: (ctx, snap) {
                  if (snap.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final pubs = snap.data ?? [];
                  if (pubs.isEmpty) {
                    return const Center(child: Text("No hay publicaciones", style: TextStyle(color: Colors.white70)));
                  }
                  return GridView.builder(
                    padding: const EdgeInsets.all(8),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3, crossAxisSpacing: 5, mainAxisSpacing: 5
                    ),
                    itemCount: pubs.length,
                    itemBuilder: (_, i) {
                      final url = pubs[i]['imagenPost'] as String? ?? '';
                      if (url.isEmpty) return Container(color: Colors.white24);
                      return ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.network(url, fit: BoxFit.cover,
                          errorBuilder: (_, __, ___)=> Container(color: Colors.redAccent),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
