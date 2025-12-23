import 'package:flutter/material.dart';
import 'customer_navigation_bar.dart';
import 'cart_page.dart';
import 'models/cart_model.dart';

const Color kPrimaryColor = Color(0xFFB7916E);
const Color kBackgroundColor = Color(0xFFF6F6F6);

class PaymentPage extends StatelessWidget {
  const PaymentPage({Key? key}) : super(key: key);

  void _showConfirmation(BuildContext context, String method) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Payment Successful'),
        content: Text('Your payment by $method has been received!'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // close dialog
              CartModel.clear(); // clear cart after payment
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const CartPage()),
                (route) => false,
              );
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final total = CartModel.totalPrice;

    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Payment',
          style: TextStyle(color: Colors.brown, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.brown),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              'Total Amount: RM ${total.toStringAsFixed(2)}',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            ListTile(
              leading: const Icon(Icons.credit_card, color: kPrimaryColor),
              title: const Text('Pay with Card'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () => _showConfirmation(context, 'Card'),
            ),
            const SizedBox(height: 12),
            ListTile(
              leading: const Icon(Icons.money, color: kPrimaryColor),
              title: const Text('Pay with Cash'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () => _showConfirmation(context, 'Cash'),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const CustomerNavigationBar(currentIndex: 2),
    );
  }
}
