import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

import 'vendor_navigation_bar.dart';
import 'vendor_orders_page.dart';

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
  int preparingOrders = 0;
  int completedOrders = 0;
  double todaySales = 0.0;

  @override
  void initState() {
    super.initState();
    _loadVendor();
    _listenOrders();
  }

  // =========================
  // LOAD VENDOR DATA
  // =========================
  void _loadVendor() {
    FirebaseDatabase.instance.ref('vendors/${widget.vendorId}').onValue.listen((
      event,
    ) {
      if (!event.snapshot.exists) return;

      final data = Map<String, dynamic>.from(event.snapshot.value as Map);
      _findTopMenu(data['menu']);

      setState(() => vendorData = data);
    });
  }

  // =========================
  // FIND TOP MENU ITEM
  // =========================
  void _findTopMenu(dynamic menuData) {
    if (menuData == null || menuData is! Map) return;

    Map<String, dynamic>? highestItem;
    int highestCount = -1;

    for (var item in menuData.values) {
      if (item is! Map) continue;

      final rawCount = item['orderCount'];
      final count = rawCount is int
          ? rawCount
          : int.tryParse(rawCount?.toString() ?? '0') ?? 0;

      if (count > highestCount) {
        highestCount = count;
        highestItem = Map<String, dynamic>.from(item);
      }
    }

    setState(() => topMenu = highestItem);
  }

  // =========================
  // LISTEN TO ORDERS
  // =========================
  void _listenOrders() {
    FirebaseDatabase.instance.ref('orders').onValue.listen((event) {
      int pending = 0;
      int preparing = 0;
      int completed = 0;
      double sales = 0.0;

      if (event.snapshot.exists) {
        final orders = Map<String, dynamic>.from(event.snapshot.value as Map);

        orders.forEach((_, orderData) {
          final order = Map<String, dynamic>.from(orderData);

          if (order['vendorId'] != widget.vendorId) return;

          switch (order['status']) {
            case 'Pending':
              pending++;
              break;
            case 'Preparing':
              preparing++;
              break;
            case 'Completed':
              completed++;
              sales += (order['totalAmount'] ?? 0).toDouble();
              break;
          }
        });
      }

      setState(() {
        newOrders = pending;
        preparingOrders = preparing;
        completedOrders = completed;
        todaySales = sales;
      });
    });
  }

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
              // Vendor info
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

              // Top menu
              const Text(
                "Today's Top Menu",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),

              if (topMenu != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Stack(
                    children: [
                      Image.asset(
                        topMenu!['menuimage'],
                        height: 160,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                      Container(
                        height: 160,
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
                      Positioned(
                        bottom: 12,
                        left: 12,
                        child: Text(
                          topMenu!['name'],
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

              const SizedBox(height: 24),

              // Dashboard cards
              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  children: [
                    _dashboardCard(
                      title: "New Orders",
                      value: newOrders.toString(),
                      index: 0,
                    ),
                    _dashboardCard(
                      title: "Orders In Progress",
                      value: preparingOrders.toString(),
                      index: 1,
                    ),
                    _dashboardCard(
                      title: "Completed Orders",
                      value: completedOrders.toString(),
                      index: 2,
                    ),
                    _salesCard(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: VendorNavigationBar(
        currentIndex: 0,
        vendorId: widget.vendorId,
      ),
    );
  }

  // =========================
  // DASHBOARD CARD
  // =========================
  Widget _dashboardCard({
    required String title,
    required String value,
    required int index,
  }) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) =>
                VendorOrdersPage(vendorId: widget.vendorId, initialTab: index),
          ),
        );
      },
      child: _cardBase(title, value),
    );
  }

  Widget _salesCard() {
    return _cardBase(
      "Today's Sales",
      "RM ${todaySales.toStringAsFixed(2)}",
      highlight: true,
    );
  }

  Widget _cardBase(String title, String value, {bool highlight = false}) {
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
          Text(
            value,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: highlight ? Colors.green : Colors.black,
            ),
          ),
          const SizedBox(height: 6),
          Text(title, style: const TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}
