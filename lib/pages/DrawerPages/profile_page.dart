import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_x_firebase/components/my_back_button.dart';
import 'package:flutter/material.dart';

class ProfilePage extends StatelessWidget {
  ProfilePage({super.key});

  final User? currentUser = FirebaseAuth.instance.currentUser;
  Future<DocumentSnapshot<Map<String, dynamic>>> getUserDetails() async {
    return await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser!.email)
        .get();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        future: getUserDetails(),
        builder: (context, snapshot) {
          // loading circle
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Text('Error ${snapshot.error}');
          } else if (snapshot.hasData) {
            // Extract Data
            Map<String, dynamic>? user = snapshot.data!.data();
            return Center(
              child: Column(
                children: [
                  const Padding(
                    padding: EdgeInsets.only(top: 50.0, left: 25.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        MyBackButton(),
                      ],
                    ),
                  ),

                  const SizedBox(
                    height: 50,
                  ),

                  // Profile pic
                  Container(
                    decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary,
                        borderRadius: BorderRadius.circular(25)),
                    padding: const EdgeInsets.all(25),
                    child: const Icon(Icons.person, size: 64),
                  ),

                  const SizedBox(height: 25),

                  Text(user!['username'],
                      style: const TextStyle(
                          fontSize: 25, fontWeight: FontWeight.bold)),

                  const SizedBox(height: 10),

                  Text(user['email'],
                      style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[600])),
                ],
              ),
            );
          } else {
            return const Text('No data');
          }
        },
      ),
    );
  }
}
