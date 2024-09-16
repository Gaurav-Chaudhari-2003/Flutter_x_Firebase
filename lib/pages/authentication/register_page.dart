import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_x_firebase/components/my_button.dart';
import 'package:flutter_x_firebase/pages/authentication/login_page.dart';
import 'package:flutter_x_firebase/components/my_text_field.dart';

import '../../helper/helper_page.dart';

class RegisterPage extends StatefulWidget {
  final void Function()? onTap;
  const RegisterPage({super.key, required this.onTap});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  // Text Controllers
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

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
                height: MediaQuery.of(context).size.height * 0.1,
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

              // Username Text Field
              MyTextField(
                  hintText: 'Username',
                  obscureText: false,
                  controller: usernameController),

              const SizedBox(height: 10),

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

              // Confirm Password Text Field
              MyTextField(
                hintText: 'Confirm Password',
                obscureText: true,
                controller: confirmPasswordController,
              ),

              const SizedBox(height: 25),

              // Register Button
              MyButton(text: 'Register', onTap: registerUser),

              const SizedBox(height: 25),

              // Register Button
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Already have an account?\t\t\t",
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.inversePrimary),
                  ),
                  GestureDetector(
                    onTap: widget.onTap,
                    child: const Text(
                      'Login Here',
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

  Future<void> registerUser() async {
    // Show loading circle
    showDialog(
        context: context,
        builder: (context) => const Center(
              child: CircularProgressIndicator(),
            ));

    // Make sure password match
    if (passwordController.text != confirmPasswordController.text) {
      Navigator.pop(context);
      displayMessageToUser("Password doesn't match!", context);
      return;
    }

    // try creating the user
    try {
      UserCredential? userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
              email: emailController.text, password: passwordController.text);

      // Add user details to firestore database
      sendToFirestore(userCredential);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User Created Successfully')),
      );
      if (context.mounted) Navigator.pop(context);
    } on Exception catch (e) {
      Navigator.pop(context);
      displayMessageToUser(e.toString(), context);
    }
  }

  Future<void> sendToFirestore(UserCredential userCredential) async {
    if (userCredential != null && userCredential.user != null) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user!.email)
          .set({
        'email': userCredential.user!.email,
        'username': usernameController.text
      });
    }
  }
}
