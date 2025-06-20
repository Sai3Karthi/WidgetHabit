import 'package:flutter/material.dart';
import 'package:widget_habit_app/models/habit.dart';
import 'package:widget_habit_app/services/habit_service.dart';

class AddHabitScreen extends StatefulWidget {
  const AddHabitScreen({super.key});

  @override
  State<AddHabitScreen> createState() => _AddHabitScreenState();
}

class _AddHabitScreenState extends State<AddHabitScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  TimeOfDay _selectedTime = TimeOfDay.now();
  Color _selectedColor = Colors.blue; // Default color
  int _targetCount = 1; // Default target count

  final HabitService _habitService = HabitService();

  void _presentTimePicker() async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (pickedTime != null && pickedTime != _selectedTime) {
      setState(() {
        _selectedTime = pickedTime;
      });
    }
  }

  void _saveHabit() async {
    if (_formKey.currentState!.validate()) {
      final newHabit = Habit(
        title: _titleController.text,
        time: _selectedTime,
        color: _selectedColor,
        targetCount: _targetCount,
      );
      await _habitService.addHabit(newHabit);
      if (!mounted) {
        return;
      } // Ensure the widget is still mounted before using context
      Navigator.pop(context, true); // Pop with true to indicate success
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Habit'),
        actions: [
          IconButton(icon: const Icon(Icons.save), onPressed: _saveHabit),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Habit Title'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a title.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.access_time),
                title: const Text('Select Time'),
                trailing: Text(_selectedTime.format(context)),
                onTap: _presentTimePicker,
              ),
              const SizedBox(height: 16),
              // Placeholder for Color Picker
              ListTile(
                leading: Icon(Icons.color_lens, color: _selectedColor),
                title: const Text('Select Color'),
                onTap: () {},
              ),
              const SizedBox(height: 16),
              // Placeholder for Target Count
              TextFormField(
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Target Count'),
                initialValue: _targetCount.toString(),
                onChanged: (value) {
                  setState(() {
                    _targetCount = int.tryParse(value) ?? 1;
                  });
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
