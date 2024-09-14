import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class MyDrawer extends StatelessWidget {
  const MyDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Theme.of(context).colorScheme.background,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Home Tile
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const DrawerHeader(child: Icon(Icons.favorite_outlined)),
              const SizedBox(height: 25),
              Padding(
                padding: const EdgeInsets.only(left: 25.0),
                child: ListTile(
                  leading: Icon(Icons.home,
                      color: Theme.of(context).colorScheme.inversePrimary),
                  title: const Text('H O M E'),
                  onTap: () {
                    // this is already the home page so just pop drawer
                    // Navigator.pushNamed(context, '/home_page');
                    Navigator.pop(context);
                    // Navigate to profile_page
                  },
                ),
              ),

              // Profile Tile
              Padding(
                padding: const EdgeInsets.only(left: 25.0),
                child: ListTile(
                  leading: Icon(Icons.person,
                      color: Theme.of(context).colorScheme.inversePrimary),
                  title: const Text('P R O F I L E'),
                  onTap: () {
                    // pop drawer
                    Navigator.pop(context);
                    // Navigate to profile_page
                    Navigator.pushNamed(context, '/profile_page');
                  },
                ),
              ),

              // Users Tile
              // Padding(
              //   padding: const EdgeInsets.only(left: 25.0),
              //   child: ListTile(
              //     leading: Icon(Icons.group,
              //         color: Theme.of(context).colorScheme.inversePrimary),
              //     title: const Text('U S E R S'),
              //     onTap: () {
              //       // pop drawer
              //       Navigator.pop(context);
              //       // Navigate to users_page
              //       Navigator.pushNamed(context, '/users_page');
              //     },
              //   ),
              // ),
            ],
          ),

          // Logout Tile
          Padding(
            padding: const EdgeInsets.only(left: 25.0, bottom: 25.0),
            child: ListTile(
              leading: Icon(Icons.logout,
                  color: Theme.of(context).colorScheme.inversePrimary),
              title: const Text('L O G O U T'),
              onTap: () {
                FirebaseAuth.instance.signOut();
                Navigator.pushNamed(context, '/login_register_page');
              },
            ),
          ),
        ],
      ),
    );
  }
}
