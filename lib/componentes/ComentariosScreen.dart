import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:red_social/services/servicioPublicacionesAPI.dart';
import 'package:red_social/paginas/auth/servicios/servicios_auth.dart';

class ComentariosScreen extends StatefulWidget {
  final String postId;
  const ComentariosScreen({super.key, required this.postId});
  @override
  State<ComentariosScreen> createState() => _ComentariosScreenState();
}

class _ComentariosScreenState extends State<ComentariosScreen> {
  final _api  = ServicioPublicacionesAPI();
  final _auth = FirebaseAuth.instance;
  final _ctrl = TextEditingController();

  late Future<List<Map<String,dynamic>>> _comentariosFuture;

  @override
  void initState() {
    super.initState();
    _loadComments();
  }

  void _loadComments() {
    _comentariosFuture = _api.obtenerPublicacion(widget.postId)
      .then((pub) {
        final list = (pub['comentarios'] as List)
          .cast<Map<String,dynamic>>();
        list.sort((a,b){
          final fa=DateTime.parse(a['fecha']), fb=DateTime.parse(b['fecha']);
          return fb.compareTo(fa);
        });
        return list;
      });
    setState(() {});
  }

  Future<void> _onSend() async {
    final txt = _ctrl.text.trim();
    if (txt.isEmpty) return;
    final uid    = _auth.currentUser!.uid;
    final nombre = await ServiciosAuth().obtenerNombreUsuario() ?? 'Anon';
    await _api.agregarComentario(
      postId: widget.postId,
      uid: uid,
      usuario: nombre,
      comentario: txt,
    );
    _ctrl.clear();
    _loadComments();
  }

  String _fmt(String iso){
    final d = DateTime.parse(iso).toLocal();
    return "${d.day}/${d.month}/${d.year} "
           "${d.hour.toString().padLeft(2,'0')}:"
           "${d.minute.toString().padLeft(2,'0')}";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Comentarios"),
        backgroundColor: Colors.black,
        actions: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.pop(context, 0),
          )
        ],
      ),
      backgroundColor: Colors.black,
      body: Column(
        children: [
          Expanded(
            child: FutureBuilder<List<Map<String,dynamic>>>(
              future: _comentariosFuture,
              builder: (ctx,snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                final coms = snap.data ?? [];
                if (coms.isEmpty) {
                  return const Center(
                    child: Text("No hay comentarios aún",
                      style: TextStyle(color:Colors.white70)),
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.only(top:8),
                  physics: const BouncingScrollPhysics(),
                  itemCount: coms.length,
                  itemBuilder: (_,i){
                    final c = coms[i];
                    return ListTile(
                      title: Text(c['usuario'] ?? '',
                        style: const TextStyle(
                          color:Colors.white,
                          fontWeight:FontWeight.bold
                        )
                      ),
                      subtitle: Text(c['comentario'] ?? '',
                        style: const TextStyle(color:Colors.white70)
                      ),
                      trailing: Text(_fmt(c['fecha'] ?? ''),
                        style: const TextStyle(color:Colors.white38,fontSize:12)
                      ),
                    );
                  },
                );
              },
            ),
          ),

          // input
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _ctrl,
                    style: const TextStyle(color:Colors.white),
                    decoration: InputDecoration(
                      hintText: "Escribe un comentario…",
                      hintStyle: const TextStyle(color:Colors.white38),
                      filled: true,
                      fillColor: Colors.white12,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send, color:Colors.white),
                  onPressed: _onSend,
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
