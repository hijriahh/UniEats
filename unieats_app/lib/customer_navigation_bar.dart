import 'package:flutter/material.dart';

import 'customer_homepage.dart';
import 'search_page.dart';
import 'cart_page.dart';
import 'customer_profile_page.dart';

class CustomerNavigationBar extends StatelessWidget {
  final int currentIndex;

  const CustomerNavigationBar({
    Key? key,
    required this.currentIndex,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final items = [
      _NavItem(icon: Icons.home_rounded, label: 'Home'),
      _NavItem(icon: Icons.search_rounded, label: 'Search'),
      _NavItem(icon: Icons.shopping_cart_rounded, label: 'Cart'),
      _NavItem(icon: Icons.person_rounded, label: 'Profile'),
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
                  page = const CustomerHomepage();
                  break;
                case 1:
                  page = const SearchPage();
                  break;
                case 2:
                  page = const CartPage();
                  break;
                default:
                  page = const ProfilePage();
              }

              // Replace current page to remove popup effect
              Navigator.push(
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

  const _NavItem({
    required this.icon,
    required this.label,
  });
}
