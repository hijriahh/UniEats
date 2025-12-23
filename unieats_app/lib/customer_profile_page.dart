import 'package:flutter/material.dart';
import 'customer_navigation_bar.dart';

const Color kBackgroundColor = Color(0xFFF6F6F6);

class ProfilePage extends StatelessWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          "Profile",
          style: TextStyle(color: Colors.brown, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const CircleAvatar(
              radius: 45,
              backgroundColor: Color(0xFFB7916E),
              child: Icon(Icons.person, size: 50, color: Colors.white),
            ),
            const SizedBox(height: 12),
            const Text(
              "Customer Name",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const Text("customer@email.com",
                style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 30),

            ListTile(
              leading: const Icon(Icons.receipt_long),
              title: const Text("Order History"),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text("Logout"),
              onTap: () {},
            ),
          ],
        ),
      ),

      bottomNavigationBar: const CustomerNavigationBar(currentIndex: 3),
    );
  }
}
