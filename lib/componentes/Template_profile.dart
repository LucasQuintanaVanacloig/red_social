// lib/paginas/Home/template_profile.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:red_social/paginas/Configuracion/settings.dart' as miSettings;
import 'package:red_social/paginas/auth/servicios/servicios_auth.dart';
import 'package:red_social/paginas/auth/servicios/servicio_seguidores.dart';
import 'package:red_social/services/servicioImagenesAPI.dart';
import 'package:red_social/services/servicioPublicacionesAPI.dart';

class TemplateProfile extends StatefulWidget {
  final String userId;
  const TemplateProfile({super.key, required this.userId});

  @override
  State<TemplateProfile> createState() => _TemplateProfileState();
}

class _TemplateProfileState extends State<TemplateProfile> {
  final ServiciosAuth _authService = ServiciosAuth();
  final ServicioSeguidores _srvSeg = ServicioSeguidores();
  final ServicioPublicacionesAPI _srvPub = ServicioPublicacionesAPI();
  final ServicioImagenesAPI _srvImg = ServicioImagenesAPI();

  late String uidActual;
  late bool esMiPerfil;

  String? nombreUsuario;
  String? urlAvatar;
  bool cargandoUsuario = true;

  bool estaSiguiendo = false;
  int seguidores = 0;
  int siguiento = 0;

  Future<List<Map<String, dynamic>>>? publicacionesFuture;

  @override
  void initState() {
    super.initState();
    uidActual = _authService.getUsuarioActualUID()!;
    esMiPerfil = widget.userId == uidActual;
    _cargarUsuario();
    _checkFollowing();
    _loadPublicaciones();
  }

  void _loadPublicaciones() {
    publicacionesFuture = _srvPub.cargarPublicaciones(widget.userId);
  }

  Future<void> _cargarUsuario() async {
    final doc = await FirebaseFirestore.instance
        .collection('Usuarios')
        .doc(widget.userId)
        .get();
    final data = doc.data()!;
    setState(() {
      nombreUsuario = data['nombre'] ?? '';
      urlAvatar     = data['imagenPerfil'] as String?;
      seguidores    = data['followersCount'] ?? 0;
      siguiento     = data['followingCount'] ?? 0;
      cargandoUsuario = false;
    });
  }

  Future<void> _checkFollowing() async {
    if (esMiPerfil) return;
    final r = await _srvSeg.estaSiguiendoA(widget.userId);
    setState(() => estaSiguiendo = r);
  }

  Future<void> _toggleFollow() async {
    if (estaSiguiendo) {
      await _srvSeg.dejarDeSeguir(widget.userId);
      seguidores--;
    } else {
      await _srvSeg.seguirUsuario(widget.userId);
      seguidores++;
    }
    setState(() => estaSiguiendo = !estaSiguiendo);
  }

  Widget _buildStat(String label, String count, VoidCallback onTap) {
    return Column(
      children: [
        Text(count,
          style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)
        ),
        GestureDetector(
          onTap: onTap,
          child: Text(label, style: const TextStyle(color: Colors.orangeAccent))
        ),
      ],
    );
  }

  void _showBottomSheet(String title) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.black87,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16))
      ),
      builder: (_) => SizedBox(
        height: 300,
        child: Center(
          child: Text(title, style: const TextStyle(color: Colors.white, fontSize: 24))
        ),
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    if (cargandoUsuario) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator(color: Colors.orangeAccent)),
      );
    }

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: true,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          nombreUsuario!,
          style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.white),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const miSettings.Settings())
            ),
          )
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFFFD5E53), Color(0xFFFD754D),
              Color(0xFFFE8714), Color(0xFFFE6900),
              Color(0xFF1A1A40)
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          )
        ),
        child: Column(
          children: [
            const SizedBox(height: 90),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.white24,
                    backgroundImage:
                        urlAvatar != null ? NetworkImage(urlAvatar!) : null,
                    child: urlAvatar == null
                        ? const Icon(Icons.person, color: Colors.white, size: 40)
                        : null,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        // publicaciones
                        FutureBuilder<List<Map<String, dynamic>>>(
                          future: publicacionesFuture,
                          builder: (ctx, snap) {
                            final t = snap.hasData
                              ? snap.data!.length.toString()
                              : '0';
                            return _buildStat('Publicaciones', t, () => _showBottomSheet('Publicaciones'));
                          },
                        ),
                        // seguidores
                        _buildStat('Seguidores', seguidores.toString(),
                          () => _showBottomSheet('Seguidores')),
                        // seguidos
                        _buildStat('Seguidos', siguiento.toString(),
                          () => _showBottomSheet('Seguidos')),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 10),
            if (!esMiPerfil)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: ElevatedButton(
                  onPressed: _toggleFollow,
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        estaSiguiendo ? Colors.white24 : Colors.orangeAccent,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 40),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: estaSiguiendo
                          ? const BorderSide(color: Colors.white30)
                          : BorderSide.none,
                    ),
                  ),
                  child: Text(
                    estaSiguiendo ? 'Siguiendo' : 'Seguir',
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ),

            const SizedBox(height: 10),
            // grid de publicaciones
            Expanded(
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: publicacionesFuture,
                builder: (ctx, snap) {
                  if (snap.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(color: Colors.orangeAccent)
                    );
                  }
                  final pubs = snap.data ?? [];
                  if (pubs.isEmpty) {
                    return const Center(
                      child: Text(
                        'Sin publicaciones',
                        style: TextStyle(color: Colors.white70),
                      ),
                    );
                  }
                  return GridView.builder(
                    padding: const EdgeInsets.all(8),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3, crossAxisSpacing: 5, mainAxisSpacing: 5
                    ),
                    itemCount: pubs.length,
                    itemBuilder: (_, i) {
                      final url = pubs[i]['imagenPost'] as String? ?? '';
                      return ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          url,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) =>
                              Container(color: Colors.white24),
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
