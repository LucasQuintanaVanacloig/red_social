import 'dart:async';                      // ← PARA EL DEBOUNCE
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:red_social/componentes/Template_profile.dart';

class Search extends StatefulWidget {
  const Search({super.key});
  @override
  _SearchState createState() => _SearchState();
}

class _SearchState extends State<Search> {
  List<Map<String, dynamic>> searchResults = [];
  List<String> recentSearches       = [];
  final TextEditingController searchController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Timer? _debounce;  // ← temporizador

  @override
  void dispose() {
    _debounce?.cancel();
    searchController.dispose();
    super.dispose();
  }

  // Llamar desde onChanged
  void _onSearchChanged(String query) {
    // Cancela un debounce anterior
    _debounce?.cancel();
    // Arranca uno nuevo de 500 ms
    _debounce = Timer(const Duration(milliseconds: 500), () {
      searchUsers(query.trim());
    });
  }

  Future<void> searchUsers(String query) async {
    if (query.isEmpty) {
      setState(() {
        searchResults.clear();
      });
      return;
    }

    // ⏱️ Solo tras debounce guardamos la búsqueda:
    setState(() {
      recentSearches.remove(query);
      recentSearches.insert(0, query);
      if (recentSearches.length > 5) {
        recentSearches = recentSearches.sublist(0, 5);
      }
    });

    // Consulta Firestore
    final users = await _firestore
        .collection("Usuarios")
        .where("nombre", isGreaterThanOrEqualTo: query)
        .where("nombre", isLessThan: '${query}z')
        .get();

    setState(() {
      searchResults = users.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80),
        child: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Padding(
            padding: const EdgeInsets.only(top: 30),
            child: TextField(
              controller: searchController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: "Buscar usuario...",
                hintStyle: const TextStyle(color: Colors.white70),
                filled: true,
                fillColor: Colors.black.withOpacity(0.3),
                prefixIcon: const Icon(Icons.search, color: Colors.white70),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear, color: Colors.white70),
                  onPressed: () {
                    searchController.clear();
                    setState(() {
                      searchResults.clear();
                    });
                  },
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: _onSearchChanged, // ← usa el debounce
            ),
          ),
        ),
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
        child: Padding(
          padding: const EdgeInsets.only(top: 0),
          child: searchController.text.isEmpty &&
                  searchResults.isEmpty
              ? _buildRecentSearches()
              : _buildSearchResults(),
        ),
      ),
    );
  }

  Widget _buildSearchResults() {
    if (searchResults.isEmpty) {
      return const Center(
        child: Text(
          "No se encontraron usuarios",
          style: TextStyle(color: Colors.white70),
        ),
      );
    }

    return ListView.builder(
      itemCount: searchResults.length,
      itemBuilder: (context, index) {
        final user = searchResults[index];
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.25),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white10),
            ),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.orange.shade300,
                child: Text(
                  user['nombre'][0].toUpperCase(),
                  style: const TextStyle(color: Colors.white),
                ),
              ),
              title: Text(user['nombre'], style: const TextStyle(color: Colors.white)),
              subtitle: Text(user['email'],
                  style: const TextStyle(color: Colors.white70, fontSize: 13)),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        TemplateProfile(userId: user['uid']),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildRecentSearches() {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 100),
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 10),
          child: Text(
            "Búsquedas recientes",
            style: TextStyle(
                color: Colors.white70,
                fontSize: 16,
                fontWeight: FontWeight.bold),
          ),
        ),
        ...recentSearches.map((query) {
          return ListTile(
            title: Text(query, style: const TextStyle(color: Colors.white)),
            trailing: const Icon(Icons.history, color: Colors.white54),
            onTap: () {
              searchController.text = query;
              _onSearchChanged(query);
            },
          );
        }).toList(),
      ],
    );
  }
}
