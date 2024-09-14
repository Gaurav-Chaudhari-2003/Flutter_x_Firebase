import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_x_firebase/components/MyButton.dart';
import 'package:flutter_x_firebase/components/MyTextField.dart';
import 'package:flutter_x_firebase/pages/DrawerPages/home_page.dart';

import '../../helper/HelperPage.dart';

class LoginPage extends StatefulWidget {
  final void Function()? onTap;
  const LoginPage({super.key, required this.onTap});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // Text Controllers
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(25.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.2,
              ),

              Icon(
                Icons.person,
                size: 80,
                color: Theme.of(context).colorScheme.inversePrimary,
              ),

              const SizedBox(height: 50),

              const Text(
                'N O T E S',
                style: TextStyle(fontSize: 20),
              ),

              const SizedBox(height: 50),

              // Email Text Field
              MyTextField(
                  hintText: 'Email',
                  obscureText: false,
                  controller: emailController),

              const SizedBox(height: 10),

              // Password Text Field
              MyTextField(
                hintText: 'Password',
                obscureText: true,
                controller: passwordController,
              ),

              const SizedBox(height: 10),

              // Forgot Password
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  GestureDetector(
                    onTap: openNoteBox,
                    child: Text(
                      'Forgot Password?',
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.inversePrimary),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 25),

              // SignIn Button
              MyButton(text: 'SignIn', onTap: loginUser),

              const SizedBox(height: 25),

              // Register Button
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Don't have an account?\t\t\t",
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.inversePrimary),
                  ),
                  GestureDetector(
                    onTap: widget.onTap,
                    child: const Text(
                      'Register Here',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void loginUser() async {
    showDialog(
      context: context,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text,
        password: passwordController.text,
      );

      if (context.mounted) {
        Navigator.pop(context); // Close the progress dialog
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomePage()),
        );
      }
    } on FirebaseAuthException catch (e) {
      Navigator.pop(context); // Close the progress dialog
      displayMessageToUser(e.message ?? "An error occurred", context);
    }
  }

  void openNoteBox() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        content: TextField(
          controller: emailController,
          decoration: const InputDecoration(hintText: "Email"),
        ),
        actions: [
          ElevatedButton(
            onPressed: () async {
              String email = emailController.text.trim();

              // Check if the email is empty
              if (email.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Enter Email')),
                );
                return;
              }

              try {
                await FirebaseAuth.instance
                    .sendPasswordResetEmail(email: email);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content: Text('Password reset link sent to $email!')),
                );
                Navigator.pop(context);
              } catch (e) {
                Navigator.pop(context);
                displayMessageToUser(
                  "Failed to send password reset link: ${e.toString()}",
                  context,
                );
              }
            },
            child: const Text(
              'Send Reset Link',
              style: TextStyle(color: Colors.black),
            ),
          ),
        ],
      ),
    );
  }
}
