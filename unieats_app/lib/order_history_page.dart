import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

const Color kPrimaryColor = Color(0xFFB7916E);
const Color kBackgroundColor = Color(0xFFF6F6F6);

class Order {
  final String id;
  final String userId;
  final String vendorName; // Added
  final String status;
  final double total;
  final List<Map<String, dynamic>> items;

  Order({
    required this.id,
    required this.userId,
    required this.vendorName, // Added
    required this.status,
    required this.total,
    required this.items,
  });

  factory Order.fromSnapshot(Map<String, dynamic> data, String id) {
    final List rawItems = data['items'] as List? ?? [];

    final items = rawItems
        .map((e) => Map<String, dynamic>.from(e as Map))
        .toList();

    return Order(
      id: id,
      userId: data['customerId'],
      vendorName: data['vendorName'] ?? "Unknown Vendor", // Added
      status: data['status'] ?? "Pending",
      total: (data['totalAmount'] as num).toDouble(),
      items: items,
    );
  }
}

class OrderHistoryPage extends StatefulWidget {
  const OrderHistoryPage({Key? key}) : super(key: key);

  @override
  State<OrderHistoryPage> createState() => _OrderHistoryPageState();
}

class _OrderHistoryPageState extends State<OrderHistoryPage> {
  List<Order> orders = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUserOrders();
  }

  Future<void> _fetchUserOrders() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final snapshot = await FirebaseDatabase.instance
        .ref('orders')
        .orderByChild('customerId')
        .equalTo(user.uid)
        .get();

    if (!snapshot.exists) {
      setState(() {
        orders = [];
        isLoading = false;
      });
      return;
    }

    final data = Map<String, dynamic>.from(snapshot.value as Map);
    final fetchedOrders = data.entries.map((entry) {
      return Order.fromSnapshot(
        Map<String, dynamic>.from(entry.value),
        entry.key,
      );
    }).toList();

    setState(() {
      orders = fetchedOrders.reversed.toList(); // newest first
      isLoading = false;
    });
  }

  Widget _buildOrderCard(Order order) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Vendor + Order ID + Status
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  "${order.vendorName}\nOrder #${order.id.substring(0, 6)}",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: order.status == "Accepted"
                      ? Colors.green[100]
                      : Colors.orange[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  order.status,
                  style: TextStyle(
                    color: order.status == "Accepted"
                        ? Colors.green[800]
                        : Colors.orange[800],
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Items (first 2 items preview)
          ...order.items.take(2).map(
            (item) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("${item['quantity']}x ${item['name']}"),
                  Text(
                    "RM ${(item['price'] * item['quantity']).toStringAsFixed(2)}",
                  ),
                ],
              ),
            ),
          ),
          if (order.items.length > 2)
            Text(
              "+ ${order.items.length - 2} more items",
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            ),

          const Divider(height: 20, thickness: 1),
          // Total
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Total",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                "RM ${order.total.toStringAsFixed(2)}",
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: AppBar(
        title: const Text("Order History"),
        backgroundColor: Colors.white,
        titleTextStyle: const TextStyle(
          color: Colors.brown,
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.brown),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : orders.isEmpty
              ? const Center(child: Text("No orders found"))
              : ListView.builder(
                  padding: const EdgeInsets.only(top: 16, bottom: 16),
                  itemCount: orders.length,
                  itemBuilder: (context, index) {
                    return _buildOrderCard(orders[index]);
                  },
                ),
    );
  }
}
