import 'package:flutter/material.dart';

class CustomerNavigationBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CustomerNavigationBar({
    Key? key,
    required this.currentIndex,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final List<_NavItem> items = const [
      _NavItem(icon: Icons.home_rounded, label: 'Home'),
      _NavItem(icon: Icons.search_rounded, label: 'Search'),
      _NavItem(icon: Icons.shopping_cart_rounded, label: 'Cart'),
      _NavItem(icon: Icons.person_rounded, label: 'Profile'),
    ];

    return Container(
      margin: const EdgeInsets.all(17),
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFB7916E),
        borderRadius: BorderRadius.circular(35),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(items.length, (index) {
          final item = items[index];
          final bool selected = index == currentIndex;

          return GestureDetector(
            onTap: () => onTap(index),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center, // vertically center
              children: [
                Icon(
                  item.icon,
                  size: selected ? 26 : 24,
                  color: selected ? Colors.white : Colors.white70,
                ),
                const SizedBox(height: 4),
                Text(
                  item.label,
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