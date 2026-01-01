import 'package:flutter/material.dart';
import 'customer_navigation_bar.dart';
import 'models/cart_model.dart';

const Color kPrimaryColor = Color(0xFFB7916E);
const Color kBackgroundColor = Color(0xFFF6F6F6);

class TrackOrderPage extends StatelessWidget {
  final int currentStatusIndex; // 0 = Accepted, 1 = Preparing, 2 = Completed
  final bool isCancelled;

  const TrackOrderPage({
    Key? key,
    this.currentStatusIndex = 0,
    this.isCancelled = false,
  }) : super(key: key);

  final List<String> statuses = const ['Accepted', 'Preparing', 'Completed'];

  Color _statusColor(int index) {
    if (isCancelled) return Colors.red;
    if (index < currentStatusIndex) return Colors.green;
    if (index == currentStatusIndex) return kPrimaryColor;
    return Colors.grey.shade400;
  }

  Widget _buildStep(int index) {
    return Expanded(
      child: Column(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: _statusColor(index),
            child: Icon(
              index == statuses.length - 1 ? Icons.home : Icons.check,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            statuses[index],
            style: TextStyle(
              color: _statusColor(index),
              fontWeight: index == currentStatusIndex
                  ? FontWeight.bold
                  : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLine(int index) {
    return Expanded(
      child: Container(
        height: 4,
        color: index < currentStatusIndex ? Colors.green : Colors.grey.shade300,
      ),
    );
  }

  Widget _buildOrderSummary() {
    final cartItems = CartModel.items;
    double total =
        cartItems.fold(0, (sum, item) => sum + (item.price * item.quantity));

    return Container(
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.symmetric(vertical: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Order Summary',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          ...cartItems.map((item) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.fastfood, color: Colors.grey),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        '${item.name} x${item.quantity}',
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w500),
                      ),
                    ),
                    Text(
                      'RM ${(item.price * item.quantity).toStringAsFixed(2)}',
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              )),
          const Divider(height: 24, thickness: 1),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              Text(
                'RM ${total.toStringAsFixed(2)}',
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Track Your Order',
          style: TextStyle(color: Colors.brown, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.brown),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: kPrimaryColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.delivery_dining_rounded,
                size: 100,
                color: kPrimaryColor,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Your order status',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            _buildOrderSummary(),

            // Horizontal Status Tracker
            const SizedBox(height: 16),
            Row(
              children: [
                _buildStep(0),
                _buildLine(0),
                _buildStep(1),
                _buildLine(1),
                _buildStep(2),
              ],
            ),
            const SizedBox(height: 30),

            if (!isCancelled && currentStatusIndex < statuses.length - 1)
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: () {
                    // Add cancel logic if needed
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 213, 35, 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    'Cancel Order',
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
              ),

            const SizedBox(height: 20),
          ],
        ),
      ),
      bottomNavigationBar: const CustomerNavigationBar(currentIndex: 2),
    );
  }
}
