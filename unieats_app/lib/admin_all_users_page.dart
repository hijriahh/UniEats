import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

const Color kPrimaryColor = Color(0xFFB7916E);
const Color kBackgroundColor = Color(0xFFF6F6F6);

class AdminAllUsersPage extends StatefulWidget {
  const AdminAllUsersPage({Key? key}) : super(key: key);

  @override
  State<AdminAllUsersPage> createState() => _AdminAllUsersPageState();
}

class _AdminAllUsersPageState extends State<AdminAllUsersPage> {
  List<Map<String, dynamic>> users = [];

  @override
  void initState() {
    super.initState();
    _listenUsers();
  }

  void _listenUsers() {
    FirebaseDatabase.instance.ref('users').onValue.listen((event) {
      if (!event.snapshot.exists) {
        setState(() => users = []);
        return;
      }

      final data = Map<String, dynamic>.from(event.snapshot.value as Map);
      final List<Map<String, dynamic>> loaded = [];

      data.forEach((uid, userData) {
        if (userData is Map) {
          loaded.add({
            'uid': uid,
            'name': userData['name'] ?? 'Unnamed User',
            'email': userData['email'] ?? '',
          });
        }
      });

      setState(() => users = loaded);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: AppBar(
        backgroundColor: kPrimaryColor,
        elevation: 0,
        title: const Text(
          "All Users",
          style: TextStyle(color: Color.fromARGB(255, 0, 0, 0), fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Color.fromARGB(255, 0, 0, 0)),
      ),
      body: users.isEmpty
          ? const Center(child: Text("No users found"))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: users.length,
              itemBuilder: (context, index) {
                final user = users[index];

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.15),
                        blurRadius: 6,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user['name'],
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      if (user['email'].isNotEmpty)
                        Text(
                          user['email'],
                          style: const TextStyle(color: Colors.grey),
                        ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
