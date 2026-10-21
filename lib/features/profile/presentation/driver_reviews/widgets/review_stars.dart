import 'package:flutter/material.dart';

/// Five stars, the first [filled] of them gold.
class ReviewStars extends StatelessWidget {
  const ReviewStars(this.filled, {super.key, required this.size, required this.empty});

  final int filled;
  final double size;
  final Color empty;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < 5; i++)
          Icon(
            i < filled ? Icons.star_rounded : Icons.star_border_rounded,
            size: size,
            color: i < filled ? const Color(0xFFFFC107) : empty,
          ),
      ],
    );
  }
}
