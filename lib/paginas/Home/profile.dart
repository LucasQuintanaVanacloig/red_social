// lib/paginas/Home/profile.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:red_social/paginas/Configuracion/settings.dart' as miSettings;
import 'package:red_social/paginas/auth/servicios/servicios_auth.dart';
import 'package:red_social/services/servicioImagenesAPI.dart';
import 'package:red_social/services/servicioPublicacionesAPI.dart';
import 'package:red_social/componentes/Template_profile.dart';
import 'package:red_social/paginas/auth/servicios/servicio_seguidores.dart';

class Profile extends StatefulWidget {
  const Profile({Key? key, this.userId}) : super(key: key);
  final String? userId;

  @override
  ProfileState createState() => ProfileState();
}

class ProfileState extends State<Profile> {
  String? userId;
  String? nombreUsuario;
  final _authService = ServiciosAuth();
  final _apiService = ServicioPublicacionesAPI();
  final _imgService = ServicioImagenesAPI(); // ← instancia de tu API de imágenes
  final ServicioSeguidores _srvSeg = ServicioSeguidores();
  File? _imagenPerfil;
  final _nombreController = TextEditingController();

  /// Futuro con la lista de publicaciones de tu API
  Future<List<Map<String, dynamic>>>? _publicacionesFuture;

  @override
  void initState() {
    super.initState();
    userId = widget.userId ?? _authService.getUsuarioActualUID();
    _loadUserName();
    refreshPosts();
  }

  /// Público para que MainScreen lo pueda invocar
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
      nombreUsuario = nombre ?? 'Desconocido';
      _nombreController.text = nombreUsuario!;
    });
  }

  void _mostrarModalEditarPerfil() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.black87,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text(
          'Editar perfil',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            GestureDetector(
              onTap: () async {
                final picker = ImagePicker();
                final XFile? img = await picker.pickImage(source: ImageSource.gallery);
                if (img != null) {
                  setState(() => _imagenPerfil = File(img.path));
                }
              },
              child: CircleAvatar(
                radius: 48,
                backgroundColor: Colors.white24,
                backgroundImage:
                    _imagenPerfil != null ? FileImage(_imagenPerfil!) : null,
                child: _imagenPerfil == null
                    ? const Icon(Icons.camera_alt, color: Colors.white, size: 32)
                    : null,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _nombreController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white10,
                labelText: 'Nombre',
                labelStyle: const TextStyle(color: Colors.white70),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            child: const Text('Cancelar', style: TextStyle(color: Colors.white70)),
            onPressed: () => Navigator.pop(context),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepOrangeAccent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Guardar', style: TextStyle(color: Colors.white)),
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
      builder: (_) =>
          const Center(child: CircularProgressIndicator(color: Colors.orangeAccent)),
    );
    try {
      // 1) Nombre
      if (nuevoNombre.isNotEmpty) {
        await _authService.actualizarNombreUsuario(nuevoNombre);
      }
      // 2) Imagen: subimos con tu API Flask
      if (_imagenPerfil != null) {
        final url = await _imgService.uploadImage(_imagenPerfil!);
        await FirebaseFirestore.instance
            .collection('Usuarios')
            .doc(userId)
            .update({'imagenPerfil': url});
      }
      Navigator.pop(context); // cierra loader
      Navigator.pop(context); // cierra diálogo
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Perfil actualizado correctamente')),
      );
      refreshPosts(); // refresca la pantalla
    } catch (e) {
      Navigator.pop(context); // cierra loader
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al guardar: $e')),
      );
    }
  }

  Widget _buildStatColumn(String label, String count, VoidCallback onTap) {
    return Column(
      children: [
        Text(
          count,
          style: const TextStyle(
            color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold
          ),
        ),
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
          style: const TextStyle(
            color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const miSettings.Settings()),
              ).then((_) {
                refreshPosts();
              });
            },
          )
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFFFD5E53), Color(0xFFFD754D),
              Color(0xFFFE8714), Color(0xFFFE6900),
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
                  // Avatar
                  StreamBuilder<DocumentSnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection("Usuarios")
                        .doc(userId)
                        .snapshots(),
                    builder: (ctx, snap) {
                      if (!snap.hasData || snap.data!.data() == null) {
                        return const CircleAvatar(
                          radius: 40,
                          backgroundColor: Colors.white24,
                          child: Icon(Icons.person, size: 40, color: Colors.white),
                        );
                      }
                      final data = snap.data!.data() as Map<String, dynamic>;
                      final url = data['imagenPerfil'] as String?;
                      return CircleAvatar(
                        radius: 40,
                        backgroundImage: url != null ? NetworkImage(url) : null,
                        backgroundColor: Colors.white24,
                        child: url == null
                            ? const Icon(Icons.person, size: 40, color: Colors.white)
                            : null,
                      );
                    },
                  ),
                  const SizedBox(width: 16),
                  // Tres contadores
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        // 1) Publicaciones (API)
                        FutureBuilder<List<Map<String, dynamic>>>(
                          future: _publicacionesFuture,
                          builder: (ctx, snap) {
                            String total;
                            if (snap.connectionState == ConnectionState.waiting) {
                              total = '...';
                            } else if (snap.hasError) {
                              total = '0';
                            } else {
                              total = snap.data!.length.toString();
                            }
                            return _buildStatColumn(
                              "Publicaciones",
                              total,
                              () => _showBottomSheet("Publicaciones"),
                            );
                          },
                        ),
                        // 2) Seguidores (Firestore)
                        StreamBuilder<DocumentSnapshot>(
                          stream: FirebaseFirestore.instance
                              .collection("Usuarios")
                              .doc(userId)
                              .snapshots(),
                          builder: (ctx, snap) {
                            final cnt = (snap.hasData && snap.data!.exists)
                                ? (snap.data!.get('followersCount') ?? 0).toString()
                                : '0';
                            return _buildStatColumn(
                              "Seguidores",
                              cnt,
                              () => _showBottomSheet("Seguidores"),
                            );
                          },
                        ),
                        // 3) Seguidos (Firestore)
                        StreamBuilder<DocumentSnapshot>(
                          stream: FirebaseFirestore.instance
                              .collection("Usuarios")
                              .doc(userId)
                              .snapshots(),
                          builder: (ctx, snap) {
                            final cnt = (snap.hasData && snap.data!.exists)
                                ? (snap.data!.get('followingCount') ?? 0).toString()
                                : '0';
                            return _buildStatColumn(
                              "Seguidos",
                              cnt,
                              () => _showBottomSheet("Seguidos"),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // Botón editar perfil
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
            // Grid de publicaciones
            Expanded(
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: _publicacionesFuture,
                builder: (ctx, snap) {
                  if (snap.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final pubs = snap.data ?? [];
                  if (pubs.isEmpty) {
                    return const Center(
                      child: Text(
                        "No hay publicaciones",
                        style: TextStyle(color: Colors.white70),
                      ),
                    );
                  }
                  return GridView.builder(
                    padding: const EdgeInsets.all(8),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 5,
                      mainAxisSpacing: 5,
                    ),
                    itemCount: pubs.length,
                    itemBuilder: (_, i) {
                      final url = pubs[i]['imagenPost'] as String? ?? '';
                      if (url.isEmpty) return Container(color: Colors.white24);
                      return ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.network(
                          url,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) =>
                              Container(color: Colors.redAccent),
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

  void _showBottomSheet(String title) {
    final isFollowers = title == "Seguidores";
    showModalBottomSheet(
      backgroundColor: Colors.black87,
      context: context,
      builder: (_) {
        return FutureBuilder<List<String>>(
          future: isFollowers
              ? _srvSeg.obtenerSeguidores(userId!)
              : _srvSeg.obtenerSeguidos(userId!),
          builder: (ctx, snapUids) {
            if (snapUids.connectionState == ConnectionState.waiting) {
              return const SizedBox(
                height: 200,
                child: Center(
                  child: CircularProgressIndicator(
                    color: Colors.orangeAccent,
                  ),
                ),
              );
            }
            if (snapUids.hasError || snapUids.data!.isEmpty) {
              return SizedBox(
                height: 200,
                child: Center(
                  child: Text(
                    snapUids.hasError
                        ? "Error cargando $title"
                        : "No tiene ${title.toLowerCase()}",
                    style: const TextStyle(color: Colors.white70),
                  ),
                ),
              );
            }
            final uids = snapUids.data!;
            return SizedBox(
              height: 300,
              child: ListView.builder(
                itemCount: uids.length,
                itemBuilder: (context, i) {
                  final otherUid = uids[i];
                  // Para cada UID, recuperamos el documento de Usuario:
                  return FutureBuilder<DocumentSnapshot>(
                    future: FirebaseFirestore.instance
                        .collection("Usuarios")
                        .doc(otherUid)
                        .get(),
                    builder: (ctx2, snapUser) {
                      if (!snapUser.hasData) {
                        return const ListTile(
                          title: Text("…", style: TextStyle(color: Colors.white)),
                        );
                      }
                      final data = snapUser.data!.data() as Map<String, dynamic>;
                      final nombre = data['nombre'] ?? 'Sin nombre';
                      final foto   = data['imagenPerfil'] as String?;
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundImage: (foto != null && foto.isNotEmpty)
                              ? NetworkImage(foto)
                              : const AssetImage("assets/img/placeholder.jpg")
                                    as ImageProvider,
                          backgroundColor: Colors.white24,
                        ),
                        title: Text(nombre, style: const TextStyle(color: Colors.white)),
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => TemplateProfile(userId: otherUid),
                            ),
                          );
                        },
                      );
                    },
                  );
                },
              ),
            );
          },
        );
      },
    );
  }
}
