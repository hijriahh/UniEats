import 'package:flutter/material.dart';

import 'vendor_homepage.dart';
import 'vendor_orders_page.dart';
import 'vendors_menu_page.dart';
import 'vendor_profile_page.dart';

class VendorNavigationBar extends StatelessWidget {
  final int currentIndex;
  final String vendorId;

  const VendorNavigationBar({
    Key? key,
    required this.currentIndex,
    required this.vendorId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final items = [
      _NavItem(icon: Icons.home_rounded, label: 'Home'),
      _NavItem(icon: Icons.receipt_long_rounded, label: 'Orders'),
      _NavItem(icon: Icons.restaurant_menu_rounded, label: 'Menu'),
      _NavItem(icon: Icons.person_rounded, label: 'Account'),
    ];

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFB7916E),
        borderRadius: BorderRadius.circular(35),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(items.length, (index) {
          final selected = index == currentIndex;

          return GestureDetector(
            onTap: () {
              if (index == currentIndex) return;

              Widget page;
              switch (index) {
                case 0:
                  page = VendorHomepage(vendorId: vendorId);
                  break;
                case 1:
                  page = VendorOrdersPage(vendorId: vendorId);
                  break;
                case 2:
                  page = VendorsMenuPage(vendorId: vendorId);
                  break;
                default:
                  page = VendorProfilePage(vendorId: vendorId);
              }

              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => page),
              );
            },
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  items[index].icon,
                  color: selected ? Colors.white : Colors.white70,
                ),
                const SizedBox(height: 4),
                Text(
                  items[index].label,
                  style: TextStyle(
                    fontSize: 12,
                    color: selected ? Colors.white : Colors.white70,
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final String label;

  const _NavItem({required this.icon, required this.label});
}
