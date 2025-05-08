import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ComentariosScreen extends StatefulWidget {
  final String postId; // ID de la publicación

  const ComentariosScreen({super.key, required this.postId});

  @override
  _ComentariosScreenState createState() => _ComentariosScreenState();
}

class _ComentariosScreenState extends State<ComentariosScreen> {
  final TextEditingController _comentarioController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Comentarios"),
        backgroundColor: Colors.black,
        actions: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () {
              Navigator.pop(context); // Cerrar la pantalla de comentarios
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Parte superior: Información de la publicación (por ejemplo, imagen, texto, etc.)
          Container(
            padding: const EdgeInsets.all(16.0),
            color: Colors.black,
            child: FutureBuilder<DocumentSnapshot>(
              future: _firestore.collection('Publicaciones').doc(widget.postId).get(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data == null) {
                  return const Center(
                    child: Text("No se pudo cargar la publicación", style: TextStyle(color: Colors.white)),
                  );
                }

                var postData = snapshot.data!.data() as Map<String, dynamic>;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Título de la publicación
                    Text(
                      postData['titulo'] ?? 'Título de la publicación', 
                      style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    // Imagen de la publicación
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.network(
                        postData['imagenPost'] ?? '',
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: 200,
                        errorBuilder: (context, error, stackTrace) {
                          return Image.asset("assets/img/placeholder.jpg", fit: BoxFit.cover);
                        },
                      ),
                    ),
                    const SizedBox(height: 10),
                    // Descripción de la publicación
                    Text(
                      postData['descripcion'] ?? 'Descripción de la publicación',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ],
                );
              },
            ),
          ),
          
          // La mitad inferior de la pantalla es para los comentarios
          Expanded(
            child: Container(
              color: Colors.black,
              child: Column(
                children: [
                  // Lista de comentarios
                  Expanded(
                    child: StreamBuilder(
                      stream: _firestore
                          .collection('Publicaciones')
                          .doc(widget.postId)
                          .collection('comentarios')
                          .orderBy('fecha', descending: true)
                          .snapshots(),
                      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator());
                        }

                        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                          return const Center(
                            child: Text("No hay comentarios aún.", style: TextStyle(color: Colors.white)),
                          );
                        }

                        return ListView.builder(
                          itemCount: snapshot.data!.docs.length,
                          itemBuilder: (context, index) {
                            var comentario = snapshot.data!.docs[index];
                            var data = comentario.data() as Map<String, dynamic>;

                            return ListTile(
                              contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                              title: Text(
                                data['usuario'] ?? 'Usuario',
                                style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                              ),
                              subtitle: Text(
                                data['comentario'] ?? '',
                                style: const TextStyle(color: Colors.white),
                              ),
                              trailing: Text(
                                _formatDate(data['fecha']),
                                style: const TextStyle(color: Colors.white, fontSize: 12),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),

                  // Campo de texto para agregar un nuevo comentario
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _comentarioController,
                            decoration: const InputDecoration(
                              hintText: "Escribe un comentario...",
                              hintStyle: TextStyle(color: Colors.white),
                              border: OutlineInputBorder(),
                              filled: true,
                              fillColor: Colors.black,
                            ),
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.send, color: Colors.white),
                          onPressed: () {
                            _agregarComentario();
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Formatear la fecha para mostrarla en un formato legible
  String _formatDate(Timestamp timestamp) {
    var date = timestamp.toDate();
    return "${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute}";
  }

  // Función para agregar un comentario
  void _agregarComentario() {
    String comentarioTexto = _comentarioController.text.trim();
    if (comentarioTexto.isNotEmpty) {
      var comentario = {
        'usuario': 'Usuario actual', // Reemplaza con el usuario real
        'comentario': comentarioTexto,
        'fecha': FieldValue.serverTimestamp(),
      };

      _firestore.collection('Publicaciones').doc(widget.postId).collection('comentarios').add(comentario);

      // Limpiar el campo de texto después de enviar el comentario
      _comentarioController.clear();
    }
  }
}
