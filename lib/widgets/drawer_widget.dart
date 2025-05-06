import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

class DrawerWidget extends StatelessWidget {
  const DrawerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    // final authProvider = Provider.of<AuthProvider>(context);
    // final user = authProvider.user;

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          GestureDetector(
            onTap: () {
              Navigator.pushNamed(
                context,
                '/profile',
              );
            },
            child: DrawerHeader(
              decoration: const BoxDecoration(
                color: Color.fromARGB(255, 205, 147, 208),
              ),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 30,
                    backgroundImage: AssetImage('assets/user-icon.jpg')
                        as ImageProvider<Object>,
                    child: null,
                  ),
                  const SizedBox(width: 16),
                  Text(
                    'Usuario',//user?.username ?? 'Guest'
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                    ),
                  ),
                ],
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text('Inicio'),
            onTap: () {
              context.push('/chat');
            },
          ),
          // ListTile(
          //   leading: const Icon(Icons.history),
          //   title: user?.rol == 'administrator'
          //       ? const Text('Alquileres')
          //       : const Text('Mis Alquileres'),
          //   onTap: () {
          //     Navigator.pushNamed(
          //       context,
          //       '/rentals',
          //     );
          //   },
          // ),
          ListTile(
            leading: const Icon(Icons.search),
            title: const Text('Busqueda de Documentos'),
            onTap: () {
              context.push('/search');
            },
          ),
          ListTile(
            leading: const Icon(Icons.grain),
            title: const Text('Preferencias de Voz'),
            onTap: () {
              context.push('/settings');
            },
          ),
          // ListTile(
          //   leading: const Icon(Icons.exit_to_app),
          //   title: const Text('Logout'),
          //   onTap: () {
          //     authProvider.logout();
          //     Navigator.of(context).pushReplacementNamed('/login');
          //   },
          // ),
        ],
      ),
    );
  }
}