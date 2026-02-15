import 'package:flutter/material.dart';

class LiquidityIndicator extends StatelessWidget {
  final String score;

  const LiquidityIndicator({super.key, required this.score});

  Color _getColor() {
    switch (score.toLowerCase()) {
      case 'high':
        return const Color(0xFF00FF41); // Matrix Green
      case 'medium':
        return Colors.yellowAccent;
      case 'low':
        return const Color(0xFFFF0055); // Bitcrush Red
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _getColor();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        border: Border.all(color: color),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.2),
            blurRadius: 8,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.circle, color: color, size: 12),
          const SizedBox(width: 8),
          Text(
            score.toUpperCase(),
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}
