import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tally_islamic/core/router/app_router.dart';

class LiveRoomScreen extends StatelessWidget {
  const LiveRoomScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Live Room'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.goNamed(AppRouter.homeRoute),
        ),
      ),
      body: const Center(child: Text('Live Room')),
    );
  }
}
