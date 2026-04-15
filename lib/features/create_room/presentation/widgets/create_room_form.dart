import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/create_room_params.dart';
import '../../domain/entities/room_entity.dart';
import '../cubit/create_room_cubit.dart';
import 'dhikr_selector.dart';
import 'duration_selector.dart';
import 'fields.dart';
import 'form_action_widgets.dart';

class CreateRoomForm extends StatefulWidget {
  final RoomType roomType;
  final void Function(CreateRoomParams) onSubmit;

  const CreateRoomForm({
    super.key, required this.roomType, required this.onSubmit,
  });

  @override
  State<CreateRoomForm> createState() => _CreateRoomFormState();
}

class _CreateRoomFormState extends State<CreateRoomForm> {
  final _nameCtrl = TextEditingController();
  final _customDhikrCtrl = TextEditingController();
  final _goalCtrl = TextEditingController(text: '100');
  final _formKey = GlobalKey<FormState>();
  final _selectedDhikr = ValueNotifier<String?>('سبحان الله');
  final _isPublic = ValueNotifier<bool>(true);
  final _selectedHours = ValueNotifier<double>(1.0);

  @override
  void dispose() {
    _nameCtrl.dispose(); _customDhikrCtrl.dispose(); _goalCtrl.dispose();
    _selectedDhikr.dispose(); _isPublic.dispose(); _selectedHours.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final dhikr = _selectedDhikr.value == 'custom'
        ? _customDhikrCtrl.text.trim() : _selectedDhikr.value ?? '';
    if (dhikr.isEmpty) return;
    final hours = widget.roomType == RoomType.free
        ? 0.5 : _selectedHours.value;
    widget.onSubmit(CreateRoomParams(
      name: _nameCtrl.text.trim(),
      type: widget.roomType == RoomType.free ? 'free' : 'paid',
      dhikr: dhikr, goal: int.tryParse(_goalCtrl.text) ?? 100,
      isPublic: _isPublic.value, durationHours: hours,
      ticketsRequired: CreateRoomParams.calculateTickets(hours),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FormHandle(color: widget.roomType == RoomType.free
                ? const Color(0xFF2E8B57) : const Color(0xFFFFD700)),
            const SizedBox(height: 20),
            RoomFormField(controller: _nameCtrl, label: 'Room Name',
                hint: 'e.g. Morning Dhikr Circle',
                validator: (v) => v == null || v.trim().isEmpty
                    ? 'Room name is required' : null),
            const SizedBox(height: 20),
            DhikrSelectorWidget(notifier: _selectedDhikr),
            ValueListenableBuilder(
              valueListenable: _selectedDhikr,
              builder: (_, val, _) => val == 'custom'
                  ? Padding(padding: const EdgeInsets.only(top: 12),
                      child: RoomFormField(controller: _customDhikrCtrl,
                          label: 'Your Dhikr',
                          hint: 'Enter custom dhikr...',
                          validator: (v) => v == null || v.trim().isEmpty
                              ? 'Please enter dhikr' : null))
                  : const SizedBox.shrink(),
            ),
            const SizedBox(height: 20),
            RoomGoalField(controller: _goalCtrl,
                roomType: widget.roomType),
            if (widget.roomType == RoomType.paid) ...[
              const SizedBox(height: 20),
              ValueListenableBuilder(
                valueListenable: _selectedHours,
                builder: (_, h, _) => DurationSelectorWidget(
                  selectedHours: h,
                  onChanged: (v) => _selectedHours.value = v,
                ),
              ),
            ],
            const SizedBox(height: 20),
            ValueListenableBuilder(
              valueListenable: _isPublic,
              builder: (_, pub, _) => VisibilityToggleRow(
                isPublic: pub,
                onToggle: () => _isPublic.value = !_isPublic.value,
              ),
            ),
            const SizedBox(height: 28),
            BlocBuilder<CreateRoomCubit, CreateRoomState>(
              builder: (context, state) => CreateRoomSubmitButton(
                isLoading: state is CreateRoomLoading,
                roomType: widget.roomType,
                onTap: _submit,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
