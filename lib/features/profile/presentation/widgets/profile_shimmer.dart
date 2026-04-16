import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import 'profile_shimmer_blocks.dart';

class ProfileShimmer extends StatelessWidget {
  const ProfileShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        child: Shimmer.fromColors(
          baseColor: Colors.grey[800]!,
          highlightColor: Colors.grey[600]!,
          child: const Column(
            children: [
              SizedBox(height: 30),
              ProfileShimmerHeader(),
              SizedBox(height: 30),
              ProfileShimmerStats(),
              SizedBox(height: 30),
              ProfileShimmerTicket(),
              SizedBox(height: 30),
              ProfileShimmerInterests(),
              SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}
