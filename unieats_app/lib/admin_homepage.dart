import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'admin_dashboard_page.dart';
import 'admin_approval_page.dart';
import 'login_page.dart';

const Color kAdminPrimary = Color(0xFFB7916E);
const Color kBackgroundColor = Color(0xFFF6F6F6);

class AdminHomepage extends StatelessWidget {
  const AdminHomepage({Key? key}) : super(key: key);

  void _logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: kBackgroundColor,
        appBar: AppBar(
          automaticallyImplyLeading: false, // ❌ remove back button
          backgroundColor: kAdminPrimary,
          elevation: 0,
          title: const Text(
            "Admin Panel",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          centerTitle: true,

          // Logout button
          actions: [
            IconButton(
              icon: const Icon(Icons.logout),
              tooltip: "Logout",
              onPressed: () => _logout(context),
            ),
          ],

          bottom: const TabBar(
            indicatorColor: Colors.white,
            tabs: [
              Tab(icon: Icon(Icons.dashboard), text: "Dashboard"),
              Tab(icon: Icon(Icons.store), text: "Vendors"),
            ],
          ),
        ),
        body: const TabBarView(
          children: [AdminDashboardPage(), AdminVendorApprovalPage()],
        ),
      ),
    );
  }
}
