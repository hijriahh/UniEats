import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

const Color kPrimaryColor = Color(0xFFB7916E);
const Color kBackgroundColor = Color(0xFFF6F6F6);

class VendorHomepage extends StatefulWidget {
  final String vendorId;

  const VendorHomepage({Key? key, required this.vendorId}) : super(key: key);

  @override
  State<VendorHomepage> createState() => _VendorHomepageState();
}

class _VendorHomepageState extends State<VendorHomepage> {
  Map<String, dynamic>? vendorData;
  Map<String, dynamic>? topMenu;

  int newOrders = 0;
  int inProgressOrders = 0;
  int completedOrders = 0;
  double todaySales = 0.0;

  @override
  void initState() {
    super.initState();
    _loadVendor();
    _loadOrders();
  }

  // =========================
  // LOAD VENDOR + TOP MENU
  // =========================
  void _loadVendor() {
    FirebaseDatabase.instance.ref('vendors/${widget.vendorId}').onValue.listen((
      event,
    ) {
      if (!event.snapshot.exists) return;

      final data = Map<String, dynamic>.from(event.snapshot.value as Map);
      setState(() {
        vendorData = data;
        _findTopMenu(data['menu']);
      });
    });
  }

  void _findTopMenu(dynamic menuData) {
    if (menuData == null || menuData is! Map) return;

    Map<String, dynamic>? highest;

    for (var item in menuData.values) {
      if (item is! Map) continue;

      final countRaw = item['orderCount'];
      final count = countRaw is int
          ? countRaw
          : int.tryParse(countRaw?.toString() ?? '0') ?? 0;

      if (highest == null) {
        highest = Map<String, dynamic>.from(item);
        highest['__count'] = count;
      } else {
        final highestCount = highest['__count'] ?? 0;
        if (count > highestCount) {
          highest = Map<String, dynamic>.from(item);
          highest['__count'] = count;
        }
      }
    }

    setState(() {
      topMenu = highest;
    });
  }

  // =========================
  // LOAD ORDERS STATS
  // =========================
  void _loadOrders() {
    FirebaseDatabase.instance.ref('orders').onValue.listen((event) {
      int pending = 0;
      int preparing = 0;
      int completed = 0;
      double sales = 0;

      if (event.snapshot.exists) {
        final orders = Map<String, dynamic>.from(event.snapshot.value as Map);

        for (var order in orders.values) {
          if (order['vendorId'] != widget.vendorId) continue;

          if (order['status'] == 'Pending') pending++;
          if (order['status'] == 'Preparing') preparing++;
          if (order['status'] == 'Completed') {
            completed++;
            sales += (order['totalAmount'] ?? 0).toDouble();
          }
        }
      }

      setState(() {
        newOrders = pending;
        inProgressOrders = preparing;
        completedOrders = completed;
        todaySales = sales;
      });
    });
  }

  // =========================
  // UI
  // =========================
  @override
  Widget build(BuildContext context) {
    if (vendorData == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Vendor Name + Location
              Text(
                vendorData!['name'],
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                "Student Pavilion, UNIMAS",
                style: TextStyle(color: Colors.grey),
              ),

              const SizedBox(height: 20),

              // Top Menu
              const Text(
                "Today's top menu",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),

              if (topMenu != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Stack(
                    children: [
                      Image.asset(
                        topMenu!['menuimage'],
                        height: 150,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),

                      // Dark overlay
                      Container(
                        height: 150,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.black.withOpacity(0.6),
                              Colors.transparent,
                            ],
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                          ),
                        ),
                      ),

                      // Menu name
                      Positioned(
                        bottom: 12,
                        left: 12,
                        right: 12,
                        child: Text(
                          topMenu!['name'] ?? '',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 20),

              // Stats Cards
              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  children: [
                    _statCard("New Orders", newOrders.toString(), Icons.add),
                    _statCard(
                      "Order In Progress",
                      inProgressOrders.toString(),
                      Icons.schedule,
                    ),
                    _statCard(
                      "Completed Orders",
                      completedOrders.toString(),
                      Icons.check_circle,
                    ),
                    _statCard(
                      "Today's Sale",
                      "RM ${todaySales.toStringAsFixed(2)}",
                      Icons.attach_money,
                      highlight: true,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _statCard(
    String title,
    String value,
    IconData icon, {
    bool highlight = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: kPrimaryColor),
          const SizedBox(height: 10),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: highlight ? Colors.green : Colors.black,
            ),
          ),
          const SizedBox(height: 4),
          Text(title, style: const TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}
