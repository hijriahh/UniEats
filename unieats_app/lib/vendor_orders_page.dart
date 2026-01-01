import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'vendor_navigation_bar.dart';

const Color kPrimaryColor = Color(0xFFB7916E);
const Color kBackgroundColor = Color(0xFFF6F6F6);

class VendorOrdersPage extends StatefulWidget {
  final String vendorId;
  final int initialTab;

  const VendorOrdersPage({
    Key? key,
    required this.vendorId,
    this.initialTab = 0,
  }) : super(key: key);

  @override
  State<VendorOrdersPage> createState() => _VendorOrdersPageState();
}

class _VendorOrdersPageState extends State<VendorOrdersPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Map<String, dynamic>> orders = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 3,
      vsync: this,
      initialIndex: widget.initialTab,
    );
    _listenOrders();
  }

  // =========================
  // LISTEN TO ORDERS
  // =========================
  void _listenOrders() {
    FirebaseDatabase.instance.ref('orders').onValue.listen((event) {
      final List<Map<String, dynamic>> loaded = [];

      if (event.snapshot.exists && event.snapshot.value is Map) {
        final data = Map<String, dynamic>.from(event.snapshot.value as Map);

        data.forEach((orderId, orderData) {
          if (orderData is Map) {
            final order = Map<String, dynamic>.from(orderData);

            if (order['vendorId'] == widget.vendorId) {
              loaded.add({'orderId': orderId, ...order});
            }
          }
        });
      }

      setState(() => orders = loaded);
    });
  }

  // =========================
  // FILTER ORDERS BY STATUS
  // =========================
  List<Map<String, dynamic>> _filterOrders(String status) {
    return orders.where((o) => o['status'] == status).toList();
  }

  // =========================
  // UPDATE ORDER STATUS
  // =========================
  void _updateStatus(String orderId, String newStatus) {
    FirebaseDatabase.instance.ref('orders/$orderId').update({
      'status': newStatus,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: AppBar(
        title: const Text("Orders"),
        backgroundColor: kPrimaryColor,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: "New"),
            Tab(text: "Preparing"),
            Tab(text: "Completed"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _ordersList(_filterOrders('Pending')),
          _ordersList(_filterOrders('Preparing')),
          _ordersList(_filterOrders('Completed')),
        ],
      ),
      bottomNavigationBar: VendorNavigationBar(
        currentIndex: 1,
        vendorId: widget.vendorId,
      ),
    );
  }

  // =========================
  // ORDER LIST UI
  // =========================
  Widget _ordersList(List<Map<String, dynamic>> list) {
    if (list.isEmpty) {
      return const Center(
        child: Text(
          "No orders available",
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: list.length,
      itemBuilder: (context, index) {
        final order = list[index];

        final List items = (order['items'] as List?) ?? [];

        return Container(
          margin: const EdgeInsets.only(bottom: 14),
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
                "Order ID: ${order['orderId']}",
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),

              // Ordered items
              ...items.map(
                (item) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(
                    "${item['name']} × ${item['quantity']}",
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
              ),

              const SizedBox(height: 10),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    order['status'],
                    style: const TextStyle(
                      color: kPrimaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Row(children: _actionButtons(order)),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  // =========================
  // ACTION BUTTONS
  // =========================
  List<Widget> _actionButtons(Map<String, dynamic> order) {
    final status = order['status'];
    final id = order['orderId'];

    if (status == 'Pending') {
      return [
        _button("Accept", Colors.green, () => _updateStatus(id, 'Preparing')),
        const SizedBox(width: 8),
        _button("Reject", Colors.red, () => _updateStatus(id, 'Rejected')),
      ];
    }

    if (status == 'Preparing') {
      return [
        _button("Complete", Colors.blue, () => _updateStatus(id, 'Completed')),
      ];
    }

    return [];
  }

  Widget _button(String label, Color color, VoidCallback onTap) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      ),
      onPressed: onTap,
      child: Text(label),
    );
  }
}
