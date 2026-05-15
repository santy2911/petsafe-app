import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../tema.dart';

class NavbarPrincipal extends StatelessWidget {
  final int indiceActual;

  const NavbarPrincipal({super.key, required this.indiceActual});

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: indiceActual,
      selectedItemColor: colorPrimario,
      unselectedItemColor: colorTextoSuave,
      onTap: (indice) {
        if (indice == 0) context.go('/home');
        if (indice == 1) context.go('/mapa');
        if (indice == 2) context.go('/perfil');
      },
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home_outlined),
          activeIcon: Icon(Icons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.map_outlined),
          activeIcon: Icon(Icons.map),
          label: 'Mapa',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_outlined),
          activeIcon: Icon(Icons.person),
          label: 'Perfil',
        ),
      ],
    );
  }
}