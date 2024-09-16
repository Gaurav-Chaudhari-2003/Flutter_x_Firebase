import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_x_firebase/services/firebase_options.dart';
import 'package:flutter_x_firebase/pages/DrawerPages/home_page.dart';
import 'package:flutter_x_firebase/pages/DrawerPages/profile_page.dart';
import 'package:flutter_x_firebase/pages/DrawerPages/users_page.dart';
import 'package:flutter_x_firebase/pages/authentication/auth_page.dart';
import 'package:flutter_x_firebase/pages/authentication/login_or_register.dart';
import 'package:flutter_x_firebase/themes/dark_mode.dart';
import 'package:flutter_x_firebase/themes/light_mode.dart';
import 'package:flutter_x_firebase/themes/theme_provider.dart';
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
