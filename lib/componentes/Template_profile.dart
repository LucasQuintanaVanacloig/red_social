import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:red_social/paginas/Configuracion/settings.dart' as miSettings;
import 'package:red_social/paginas/auth/servicios/servicios_auth.dart';
import 'package:red_social/paginas/auth/servicios/servicio_seguidores.dart';

class TemplateProfile extends StatefulWidget {
  final String? userId;

  const TemplateProfile({super.key, this.userId});

  @override
  State<TemplateProfile> createState() => _TemplateProfileState();
}

class _TemplateProfileState extends State<TemplateProfile> {
  String? userId;
  String? nomUsuari;
  bool cargando = true;

  int _seguidores = 0;
  int _seguidos = 0;

  final ServiciosAuth _authService = ServiciosAuth();
  final ServicioSeguidores _servicioSeguidores = ServicioSeguidores();

  bool _estaSiguiendo = false;
  bool _esMiPerfil = false;

  @override
  void initState() {
    super.initState();
    final uidActual = _authService.getUsuarioActualUID();
    userId = widget.userId ?? uidActual;
    _esMiPerfil = userId == uidActual;
    _cargarDatosUsuario();
    _verificarSeguimiento();
  }

  Future<void> _cargarDatosUsuario() async {
    if (userId == null) return;

    try {
      final doc = await FirebaseFirestore.instance.collection("Usuarios").doc(userId).get();

      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;

        setState(() {
          nomUsuari = data['nombre'] ?? "Sin nombre";
          _seguidores = data['followersCount'] ?? 0;
          _seguidos = data['followingCount'] ?? 0;
          cargando = false;
        });
      } else {
        print("❌ Documento no existe para UID: $userId");
        setState(() {
          nomUsuari = "No encontrado";
          cargando = false;
        });
      }
    } catch (e) {
      print("❌ Error en _cargarDatosUsuario: $e");
      setState(() {
        nomUsuari = "Error";
        cargando = false;
      });
    }
  }

  Future<void> _verificarSeguimiento() async {
    if (_esMiPerfil || userId == null) return;

    bool resultado = await _servicioSeguidores.estaSiguiendoA(userId!);
    setState(() {
      _estaSiguiendo = resultado;
    });
  }

  Future<void> _alternarSeguimiento() async {
    if (userId == null) return;

    if (_estaSiguiendo) {
      await _servicioSeguidores.dejarDeSeguir(userId!);
    } else {
      await _servicioSeguidores.seguirUsuario(userId!);
    }

    await _cargarDatosUsuario();

    setState(() {
      _estaSiguiendo = !_estaSiguiendo;
    });
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

  @override
  Widget build(BuildContext context) {
    if (cargando) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
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
          nomUsuari ?? 'Desconocido',
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const miSettings.Settings()),
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
                        StreamBuilder<QuerySnapshot>(
                          stream: FirebaseFirestore.instance
                              .collection('Publicaciones')
                              .where('userId', isEqualTo: userId)
                              .snapshots(),
                          builder: (context, snapshot) {
                            final total = snapshot.hasData ? snapshot.data!.docs.length.toString() : '0';
                            return _buildStatColumn("Publicaciones", total, () => _showBottomSheet("Publicaciones"));
                          },
                        ),
                        _buildStatColumn("Seguidores", _seguidores.toString(), () => _showBottomSheet("Seguidores")),
                        _buildStatColumn("Seguidos", _seguidos.toString(), () => _showBottomSheet("Seguidos")),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            if (!_esMiPerfil)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: ElevatedButton(
                  onPressed: _alternarSeguimiento,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _estaSiguiendo ? Colors.white24 : Colors.orange.shade600,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 40),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                      side: _estaSiguiendo
                          ? const BorderSide(color: Colors.white38)
                          : BorderSide.none,
                    ),
                  ),
                  child: Text(
                    _estaSiguiendo ? "Siguiendo" : "Seguir",
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                ),
              ),
            const SizedBox(height: 10),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('Publicaciones')
                    .where('userId', isEqualTo: userId)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final publicaciones = snapshot.data!.docs;

                  if (publicaciones.isEmpty) {
                    return const Center(
                      child: Text("Sin publicaciones", style: TextStyle(color: Colors.white70)),
                    );
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
                      final data = publicaciones[index].data() as Map<String, dynamic>;
                      final imagenUrl = data['imagenUrl'];

                      return ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.network(
                          imagenUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image, color: Colors.white),
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
