import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_x_firebase/services/firebase_options.dart';
import 'package:flutter_x_firebase/pages/DrawerPages/home_page.dart';
import 'package:flutter_x_firebase/pages/DrawerPages/ProfilePage.dart';
import 'package:flutter_x_firebase/pages/DrawerPages/UsersPage.dart';
import 'package:flutter_x_firebase/pages/authentication/AuthPage.dart';
import 'package:flutter_x_firebase/pages/authentication/LoginOrRegister.dart';
import 'package:flutter_x_firebase/themes/DarkMode.dart';
import 'package:flutter_x_firebase/themes/LightMode.dart';
import 'package:flutter_x_firebase/themes/ThemeProvider.dart';
import 'package:provider/provider.dart'; // Import provider package

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ThemeProvider(), // Provide ThemeProvider
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            home: const AuthPage(),
            theme: lightMode,
            darkTheme: darkMode,
            themeMode: themeProvider.themeMode, // Apply theme mode
            routes: {
              '/login_register_page': (context) => const LoginOrRegister(),
              '/home_page': (context) => const HomePage(),
              '/profile_page': (context) => ProfilePage(),
              '/users_page': (context) => const UsersPage(),
            },
          );
        },
      ),
    );
  }
}
