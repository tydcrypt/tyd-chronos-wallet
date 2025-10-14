import 'package:flutter/material.dart';

class PlaceholderLogo extends StatelessWidget {
  final double size;
  
  const PlaceholderLogo({super.key, this.size = 50.0});
  
  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: const Color(0xFFD4AF37),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: // ignore: deprecated_member_use
          Colors.black.withOpacity(0.3),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: Icon(
          Icons.account_balance_wallet,
          color: Colors.black,
          size: size * 0.6,
        ),
      ),
    );
  }
}
