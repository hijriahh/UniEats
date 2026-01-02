import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'admin_all_vendors_page.dart';
import 'admin_all_users_page.dart';

const Color kPrimaryColor = Color(0xFFB7916E);
const Color kBackgroundColor = Color(0xFFF6F6F6);

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({Key? key}) : super(key: key);

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  int totalUsers = 0;
  int totalVendors = 0;
  int pendingVendors = 0;

  @override
  void initState() {
    super.initState();
    _listenData();
  }

  void _listenData() {
    FirebaseDatabase.instance.ref('users').onValue.listen((event) {
      if (!event.snapshot.exists) return;
      setState(() {
        totalUsers = (event.snapshot.value as Map).length;
      });
    });

    FirebaseDatabase.instance.ref('vendors').onValue.listen((event) {
      if (!event.snapshot.exists) return;

      final data = Map<String, dynamic>.from(event.snapshot.value as Map);
      int pending = 0;

      data.forEach((_, vendor) {
        if (vendor is Map && vendor['approved'] == false) {
          pending++;
        }
      });

      setState(() {
        totalVendors = data.length;
        pendingVendors = pending;
      });
    });
  }

  Widget _card({
    required String title,
    required String value,
    required IconData icon,
    VoidCallback? onTap,
  }) {
    final card = Container(
      margin: const EdgeInsets.all(6),
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
          Icon(icon, color: kPrimaryColor, size: 28),
          const SizedBox(height: 12),
          Text(title, style: const TextStyle(color: Colors.grey)),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );

    return Expanded(
      child: onTap == null ? card : GestureDetector(onTap: onTap, child: card),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // =====================
            // TOP STATS
            // =====================
            Row(
              children: [
                _card(
                  title: "Total Users",
                  value: totalUsers.toString(),
                  icon: Icons.people,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const AdminAllUsersPage(),
                      ),
                    );
                  },
                ),
                _card(
                  title: "Total Vendors",
                  value: totalVendors.toString(),
                  icon: Icons.store,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const AdminAllVendorsPage(),
                      ),
                    );
                  },
                ),
              ],
            ),

            const SizedBox(height: 16),

            // =====================
            // PENDING TASKS
            // =====================
            Row(
              children: [
                _card(
                  title: "Pending Vendor Approvals",
                  value: pendingVendors.toString(),
                  icon: Icons.pending_actions,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
