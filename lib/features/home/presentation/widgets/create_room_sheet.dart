import 'dart:developer';
import 'dart:math' hide log;

import 'package:flutter/material.dart';
import 'package:tally_islamic/core/helper/show_snak_bar.dart';

import '../../../../../core/theme/app_colors.dart';
import 'create_room_form_widgets.dart';
import 'create_room_type_sheet.dart';
import 'room_title_row.dart';
import 'sheet_components.dart';

class CreateRoomSheet extends StatefulWidget {
  final RoomType roomType;
  const CreateRoomSheet({super.key, required this.roomType});
  @override
  State<CreateRoomSheet> createState() => _CreateRoomSheetState();
}

class _CreateRoomSheetState extends State<CreateRoomSheet> {
  final _nameCtrl = TextEditingController();
  final _customDhikrCtrl = TextEditingController();
  final _countCtrl = TextEditingController(text: '33');
  final _formKey = GlobalKey<FormState>();
  String? _selectedDhikr;
  bool _isPublic = true, _isLoading = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _customDhikrCtrl.dispose();
    _countCtrl.dispose();
    super.dispose();
  }

  String _generateRoomId() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final rand = Random.secure();
    return List.generate(8, (_) => chars[rand.nextInt(chars.length)]).join();
  }

  Future<void> _createRoom() async {
    if (!_formKey.currentState!.validate()) return;
    final dhikr = _selectedDhikr == 'custom'
        ? _customDhikrCtrl.text.trim()
        : _selectedDhikr;
    if (dhikr == null || dhikr.isEmpty) {
      log('Validation failed: No dhikr selected or entered');
      showSnakBar(context, 'Please select or enter a dhikr.', isError: true);
      return;
    }
    setState(() => _isLoading = true);
    final roomId = _generateRoomId();
    log(
      '[CreateRoom] type=${widget.roomType.name} id=$roomId '
      'dhikr=$dhikr count=${_countCtrl.text} public=$_isPublic',
    );
    await Future.delayed(const Duration(seconds: 1));
    if (!mounted) return;
    setState(() => _isLoading = false);

    showSnakBar(context, 'Room created! ID: $roomId', isError: false);
    Navigator.pop(context);
  }

  Color get _color =>
      widget.roomType == RoomType.free ? AppColors.primary : AppColors.gold;

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
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SheetHandle(),
                const SizedBox(height: 20),
                RoomTitleRow(
                  color: _color,
                  label: widget.roomType == RoomType.free
                      ? 'Free Room'
                      : 'Paid Room',
                  badge: widget.roomType == RoomType.free ? '30 min' : '6 hrs+',
                ),
                const SizedBox(height: 24),
                SheetTextField(
                  controller: _nameCtrl,
                  label: 'Room Name',
                  hint: 'e.g. Morning Dhikr Circle',
                  validator: (v) => v == null || v.trim().isEmpty
                      ? 'Room name is required'
                      : null,
                ),
                const SizedBox(height: 20),
                DhikrSelectorWidget(
                  selectedDhikr: _selectedDhikr,
                  onSelected: (d) => setState(() => _selectedDhikr = d),
                ),
                if (_selectedDhikr == 'custom') ...[
                  const SizedBox(height: 12),
                  SheetTextField(
                    controller: _customDhikrCtrl,
                    label: 'Your Dhikr',
                    hint: 'Enter custom dhikr...',
                    validator: (v) => v == null || v.trim().isEmpty
                        ? 'Please enter your dhikr'
                        : null,
                  ),
                ],
                const SizedBox(height: 20),
                SheetTextField(
                  controller: _countCtrl,
                  label: 'Count Goal',
                  hint: '33',
                  keyboardType: TextInputType.number,
                  suffix: 'times',
                  validator: (v) {
                    final n = int.tryParse(v ?? '');
                    if (n == null || n <= 0) return 'Enter a valid number';
                    final max = widget.roomType == RoomType.free
                        ? 2000
                        : 1000000;
                    if (n > max) return 'Max is $max for this type';
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                VisibilityToggle(
                  isPublic: _isPublic,
                  onToggle: () => setState(() => _isPublic = !_isPublic),
                ),
                const SizedBox(height: 28),
                CreateRoomButton(
                  roomType: widget.roomType,
                  isLoading: _isLoading,
                  onTap: _createRoom,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
