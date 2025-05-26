import 'package:flutter/material.dart';
import 'package:red_social/paginas/Home/home.dart';
import 'package:red_social/paginas/Home/search.dart';
import 'package:red_social/paginas/Home/CreatePage.dart';
import 'package:red_social/paginas/Home/profile.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});
  @override
  MainScreenState createState() => MainScreenState();
}

class MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  final _homeKey    = GlobalKey<HomeState>();
  final _profileKey = GlobalKey<ProfileState>();

  late final List<Widget> _screens;

  MainScreenState() {
    _screens = [
      Home(key: _homeKey),
      const Search(),
      // Injectamos CreatePage con el callback
      CreatePage(onPublish: () {
        _homeKey.currentState?.refreshPosts();
        _profileKey.currentState?.refreshPosts();
      }),
      Profile(key: _profileKey),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.black,
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white70,
        type: BottomNavigationBarType.fixed,
        onTap: (idx) {
          setState(() => _selectedIndex = idx);
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home),   label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: "Buscar"),
          BottomNavigationBarItem(icon: Icon(Icons.add),    label: "Añadir"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Perfil"),
        ],
      ),
    );
  }
}
