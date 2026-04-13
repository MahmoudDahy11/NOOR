import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:tally_islamic/core/helper/show_snak_bar.dart';

import 'join_room_widgets.dart';

class JoinRoomSheet extends StatefulWidget {
  const JoinRoomSheet({super.key});
  @override
  State<JoinRoomSheet> createState() => _JoinRoomSheetState();
}

class _JoinRoomSheetState extends State<JoinRoomSheet> {
  final _idCtrl = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _idCtrl.dispose();
    super.dispose();
  }

  Future<void> _join() async {
    final id = _idCtrl.text.trim().toUpperCase();
    if (id.length != 8) {
      log('Validation failed: Room ID must be 8 characters. Entered: "$id"');
      showSnakBar(context, 'Room ID must be 8 characters.', isError: true);
      return;
    }
    setState(() => _isLoading = true);
    log('[JoinRoom] Attempting to join room: $id');
    await Future.delayed(const Duration(seconds: 1));
    if (!mounted) return;
    setState(() => _isLoading = false);

    showSnakBar(context, 'Joining room $id...', isError: false);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: Container(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const JoinSheetHandle(),
            const SizedBox(height: 24),
            const JoinSheetHeader(),
            const SizedBox(height: 24),
            JoinIdField(controller: _idCtrl),
            const SizedBox(height: 24),
            JoinButton(isLoading: _isLoading, onTap: _join),
          ],
        ),
      ),
    );
  }
}
