import 'package:flutter/material.dart';

class ProfileShimmerHeader extends StatelessWidget {
  const ProfileShimmerHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        _Box(100, 100, circle: true),
        SizedBox(height: 16),
        _Box(150, 24),
        SizedBox(height: 8),
        _Box(100, 16),
        SizedBox(height: 16),
        _Box(250, 14),
        SizedBox(height: 4),
        _Box(200, 14),
      ],
    );
  }
}

class ProfileShimmerStats extends StatelessWidget {
  const ProfileShimmerStats({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(
          3,
          (_) => const Column(
            children: [_Box(40, 24), SizedBox(height: 8), _Box(60, 14)],
          ),
        ),
      ),
    );
  }
}

class ProfileShimmerTicket extends StatelessWidget {
  const ProfileShimmerTicket({super.key});

  @override
  Widget build(BuildContext context) => const Padding(
    padding: EdgeInsets.symmetric(horizontal: 24),
    child: _Box(double.infinity, 80),
  );
}

class ProfileShimmerInterests extends StatelessWidget {
  const ProfileShimmerInterests({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Box(100, 20),
          SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _Box(70, 35),
              _Box(80, 35),
              _Box(90, 35),
              _Box(100, 35),
              _Box(110, 35),
            ],
          ),
        ],
      ),
    );
  }
}

class _Box extends StatelessWidget {
  const _Box(this.width, this.height, {this.circle = false});

  final double width;
  final double height;
  final bool circle;

  @override
  Widget build(BuildContext context) => Container(
    width: width,
    height: height,
    decoration: BoxDecoration(
      color: Colors.white,
      shape: circle ? BoxShape.circle : BoxShape.rectangle,
      borderRadius: circle ? null : BorderRadius.circular(12),
    ),
  );
}
