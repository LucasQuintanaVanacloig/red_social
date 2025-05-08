import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:red_social/paginas/Configuracion/settings.dart' as miSettings;
import 'package:red_social/paginas/auth/servicios/servicios_auth.dart';

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

  final ServiciosAuth _authService = ServiciosAuth();

  @override
  void initState() {
    super.initState();
    userId = widget.userId ?? _authService.getUsuarioActualUID();
    _cargarNombreUsuario();
    print("🔹 userId en TemplateProfile: $userId");
  }

  Future<void> _cargarNombreUsuario() async {
    if (userId == null) return;

    try {
      final doc = await FirebaseFirestore.instance.collection("Usuarios").doc(userId).get();

      if (doc.exists) {
        setState(() {
          nomUsuari = doc.get("nombre") ?? "Sin nombre";
          cargando = false;
        });
      } else {
        setState(() {
          nomUsuari = "No encontrado";
          cargando = false;
        });
      }
    } catch (e) {
      setState(() {
        nomUsuari = "Error";
        cargando = false;
      });
    }
  }

  void _showBottomSheet(String title) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16),
          height: 300,
          child: Column(
            children: [
              Text(
                title,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const Divider(),
              Expanded(
                child: ListView.builder(
                  itemCount: 10,
                  itemBuilder: (context, index) {
                    return ListTile(
                      leading: const CircleAvatar(
                        backgroundColor: Colors.grey,
                        child: Icon(Icons.person, color: Colors.white),
                      ),
                      title: Text("Usuario $index"),
                      subtitle: const Text("Descripción corta"),
                      trailing: ElevatedButton(
                        onPressed: () {},
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
    if (cargando) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      automaticallyImplyLeading: false, // Desactivamos el auto-leading
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.black),
        onPressed: () {
          Navigator.pop(context); // Vuelve atrás
        },
      ),
      title: Text(
        "Perfil de ${nomUsuari ?? 'Desconocido'}",
        style: const TextStyle(color: Colors.black),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.settings, color: Colors.black),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const miSettings.Settings()),
            );
          },
        ),
      ],
    ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                const CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.grey,
                  child: Icon(Icons.person, size: 40, color: Colors.white),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        nomUsuari ?? "Nombre no disponible",
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          GestureDetector(
                            onTap: () => _showBottomSheet("Publicaciones"),
                            child: const Text("Publicaciones", style: TextStyle(color: Colors.blue)),
                          ),
                          GestureDetector(
                            onTap: () => _showBottomSheet("Seguidores"),
                            child: const Text("Seguidores", style: TextStyle(color: Colors.blue)),
                          ),
                          GestureDetector(
                            onTap: () => _showBottomSheet("Seguidos"),
                            child: const Text("Seguidos", style: TextStyle(color: Colors.blue)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Read More >",
                style: TextStyle(color: Colors.blue),
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
                  color: Colors.grey[300],
                  child: const Center(child: Icon(Icons.add, size: 40, color: Colors.grey)),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
