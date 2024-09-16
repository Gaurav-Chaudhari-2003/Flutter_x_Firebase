import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_x_firebase/components/my_back_button.dart';
import 'package:flutter_x_firebase/components/my_list_tile.dart';

class UsersPage extends StatelessWidget {
  const UsersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(

        leading: const Padding(
          padding: EdgeInsets.only(left: 12, top: 10),
          child: MyBackButton(),
        ),
        backgroundColor: Theme.of(context).colorScheme.background,
        elevation: 0,
      ),
      backgroundColor: Theme.of(context).colorScheme.background,
      body: StreamBuilder(
          stream: FirebaseFirestore.instance.collection('users').snapshots(),
          builder: (context, snapshot) {
            // loading circle
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Text('Error ${snapshot.error}');
            }
            if (snapshot.hasData) {
              if (snapshot.data == null) {
                return const Text('No data');
              }

              // get all users
              final users = snapshot.data!.docs;
              return ListView.builder(
                itemCount: users.length,
                itemBuilder: (context, index) {
                  // get individual user
                  final user = users[index];

                  String username = user['username'], email = user['email'];

                  return MyListTile(title: username, subtitle: email);
                },
              );
            } else {
              return const Text('No data');
            }
          }),
    );
  }
}
