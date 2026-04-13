import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class TicketCardShimmer extends StatelessWidget {
  const TicketCardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Shimmer.fromColors(
        baseColor: const Color(0xFFE0C84A),
        highlightColor: const Color(0xFFFFD700),
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFFDAA520),
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      ),
    );
  }
}
