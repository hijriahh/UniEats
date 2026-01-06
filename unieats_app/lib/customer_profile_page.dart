import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'customer_navigation_bar.dart';
import 'login_page.dart';

// Dummy pages for navigation (replace with your actual pages)
import 'order_history_page.dart';
import 'edit_profile_page.dart';

const Color kBackgroundColor = Color(0xFFF6F6F6);
const Color kPrimaryColor = Color(0xFFB7916E);

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String customerName = "";
  String customerEmail = "";
  bool isLoading = true;
  bool notificationsEnabled = false;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final uid = user.uid;
      final ref = FirebaseDatabase.instance.ref('users/$uid');
      final snapshot = await ref.get();

      if (snapshot.exists) {
        final data = Map<String, dynamic>.from(snapshot.value as Map);
        setState(() {
          customerName = data['name'] ?? "No Name";
          customerEmail = data['email'] ?? user.email ?? "No Email";
          notificationsEnabled = data['notifications'] ?? false;
          isLoading = false;
        });
      } else {
        setState(() {
          customerName = user.displayName ?? "No Name";
          customerEmail = user.email ?? "No Email";
          isLoading = false;
        });
      }
    }
  }

  Widget _buildActionTile({
    required IconData icon,
    required String label,
    VoidCallback? onTap,
    Color? iconColor,
    Widget? trailing,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: (iconColor ?? kPrimaryColor).withOpacity(0.15),
              child: Icon(icon, color: iconColor ?? kPrimaryColor),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
            if (trailing != null)
              trailing
            else
              const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      bottomNavigationBar: const CustomerNavigationBar(currentIndex: 3),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.brown),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Profile",
          style: TextStyle(color: Colors.brown, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  // Profile Avatar
                  Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: kPrimaryColor,
                        child: const Icon(Icons.person, size: 50, color: Colors.white),
                      ),
                      // Camera icon placeholder
                      Container(
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        padding: const EdgeInsets.all(4),
                        child: const CircleAvatar(
                          radius: 12,
                          backgroundColor: kPrimaryColor,
                          child: Icon(Icons.camera_alt, size: 16, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    customerName,
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    customerEmail,
                    style: const TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                  const SizedBox(height: 30),

                  // Action tiles
                  Column(
                    children: [
                      _buildActionTile(
                        icon: Icons.receipt_long,
                        label: "Order History",
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const OrderHistoryPage()),
                          );
                        },
                      ),
                      _buildActionTile(
                        icon: Icons.edit,
                        label: "Edit Profile",
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => EditProfilePage(
                              name: customerName,
                              email: customerEmail,
                              onUpdate: (newName, newEmail) {
                                setState(() {
                                  customerName = newName;
                                  customerEmail = newEmail;
                                });
                              },
                            )),
                          );
                        },
                      ),
          
                      _buildActionTile(
                        icon: Icons.logout,
                        iconColor: Colors.red,
                        label: "Logout",
                        onTap: () async {
                          await FirebaseAuth.instance.signOut();
                          // Go to login and remove all previous pages
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(builder: (_) => const LoginScreen()),
                            (route) => false,
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
    );
  }
}
