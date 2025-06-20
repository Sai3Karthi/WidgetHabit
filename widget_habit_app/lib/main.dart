import 'package:flutter/material.dart';
import 'package:widget_habit_app/models/habit.dart';
import 'package:widget_habit_app/services/habit_service.dart';
import 'package:widget_habit_app/services/widget_service.dart';
import 'package:widget_habit_app/widgets/weekly_habit_card.dart';
import 'package:widget_habit_app/utils/app_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize widget service
  WidgetService.initialize();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Goals',
      theme: AppTheme.darkTheme,
      home: const GoalsScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class GoalsScreen extends StatefulWidget {
  const GoalsScreen({super.key});

  @override
  State<GoalsScreen> createState() => _GoalsScreenState();
}

class _GoalsScreenState extends State<GoalsScreen> with WidgetsBindingObserver {
  List<Habit> _habits = [];
  DateTime _currentWeekStart = DateTime.now();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _currentWeekStart = _getWeekStart(DateTime.now());
    _loadHabits();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _loadHabits();
    }
  }

  DateTime _getWeekStart(DateTime date) {
    // Get Monday of the current week
    int weekday = date.weekday;
    return date.subtract(Duration(days: weekday - 1));
  }

  String get _weekDisplayText {
    final now = DateTime.now();
    final thisWeekStart = _getWeekStart(now);

    if (_currentWeekStart.isAtSameMomentAs(thisWeekStart)) {
      return 'Week view';
    } else if (_currentWeekStart.isBefore(thisWeekStart)) {
      final weeksDiff = thisWeekStart.difference(_currentWeekStart).inDays ~/ 7;
      return '$weeksDiff week${weeksDiff > 1 ? 's' : ''} ago';
    } else {
      final weeksDiff = _currentWeekStart.difference(thisWeekStart).inDays ~/ 7;
      return 'In $weeksDiff week${weeksDiff > 1 ? 's' : ''}';
    }
  }

  String get _currentDateText {
    final today = DateTime.now();
    final isCurrentWeek =
        _currentWeekStart.isBefore(today.add(const Duration(days: 1))) &&
        _currentWeekStart.add(const Duration(days: 7)).isAfter(today);

    if (isCurrentWeek) {
      return '${today.day}';
    } else {
      final endDate = _currentWeekStart.add(const Duration(days: 6));
      return '${_currentWeekStart.day}-${endDate.day}';
    }
  }

  String get _monthYearText {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return '${months[_currentWeekStart.month - 1]} ${_currentWeekStart.year}';
  }

  Future<void> _loadHabits() async {
    final prefs = await SharedPreferences.getInstance();
    final String? habitsJson = prefs.getString('habits');
    List<Habit> loadedHabits = [];
    if (habitsJson != null) {
      final List<dynamic> habitList = json.decode(habitsJson);
      loadedHabits = habitList.map((json) => Habit.fromJson(json)).toList();
    }
    if (mounted) {
      setState(() {
        _habits = loadedHabits;
      });
      // Update widget when app is loaded/resumed
      await WidgetService.updateWidgetData(loadedHabits);
    }
  }

  Future<void> _saveHabits() async {
    final prefs = await SharedPreferences.getInstance();
    final List<Map<String, dynamic>> habitList = _habits
        .map((h) => h.toJson())
        .toList();
    await prefs.setString('habits', json.encode(habitList));
  }

  void _addHabit(
    String title,
    TimeOfDay time,
    Color color,
    bool isFavorite,
  ) async {
    final newHabit = Habit(
      title: title,
      time: time,
      color: color,
      isFavorite: isFavorite,
    );
    setState(() {
      _habits.add(newHabit);
    });
    await _saveHabits();
    await WidgetService.updateWidgetData(_habits);
    if (mounted) Navigator.of(context).pop();
  }

  void _onHabitCompletionChanged(Habit habit, DateTime date) async {
    setState(() {
      // Cycle through states: 0 (none) -> 1 (completed) -> 2 (skipped) -> 0
      final currentStatus = habit.getCompletionStatus(date);
      final nextStatusValue =
          (CompletionStatus.values.indexOf(currentStatus) + 1) % 3;
      final nextStatus = CompletionStatus.values[nextStatusValue];
      habit.setCompletionStatus(date, nextStatus);
    });
    await _saveHabits();
    await WidgetService.updateWidgetData(_habits);
  }

  void _onHabitFavorited(Habit habit) async {
    setState(() {
      habit.isFavorite = !habit.isFavorite;
    });
    await _saveHabits();
    await WidgetService.updateWidgetData(_habits);
  }

  void _deleteHabit(Habit habit) async {
    setState(() {
      _habits.remove(habit);
    });
    await _saveHabits();
    await WidgetService.updateWidgetData(_habits);
  }

  void _showAddHabitSheet() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: AddHabitSheet(onAdd: _addHabit),
        );
      },
    );
  }

  void _navigateWeek(bool isNext) {
    setState(() {
      _currentWeekStart = _currentWeekStart.add(
        Duration(days: isNext ? 7 : -7),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryBackground,
      appBar: AppBar(
        backgroundColor: AppTheme.primaryBackground,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.menu, color: AppTheme.primaryText),
          onPressed: () {},
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(_weekDisplayText, style: AppTheme.titleLarge),
            Text(_monthYearText, style: AppTheme.bodySmall),
          ],
        ),
        centerTitle: false,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: AppTheme.spaceM),
            padding: const EdgeInsets.symmetric(
              horizontal: AppTheme.spaceM,
              vertical: AppTheme.spaceS,
            ),
            decoration: BoxDecoration(
              color: AppTheme.surfaceColor,
              borderRadius: BorderRadius.circular(AppTheme.radiusM),
              border: Border.all(color: AppTheme.currentDayHighlight, width: 1),
            ),
            child: Text(
              _currentDateText,
              style: AppTheme.titleMedium.copyWith(
                color: AppTheme.currentDayHighlight,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.more_vert, color: AppTheme.primaryText),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          // Week navigation
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppTheme.spaceM,
              vertical: AppTheme.spaceS,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  onPressed: () => _navigateWeek(false),
                  icon: const Icon(
                    Icons.chevron_left,
                    color: AppTheme.primaryText,
                    size: 28,
                  ),
                ),
                IconButton(
                  onPressed: () => _navigateWeek(true),
                  icon: const Icon(
                    Icons.chevron_right,
                    color: AppTheme.primaryText,
                    size: 28,
                  ),
                ),
              ],
            ),
          ),
          // Habits list
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      color: AppTheme.accentBlue,
                    ),
                  )
                : _habits.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.track_changes_outlined,
                          size: 64,
                          color: AppTheme.tertiaryText,
                        ),
                        const SizedBox(height: AppTheme.spaceM),
                        Text(
                          'No habits yet',
                          style: AppTheme.titleLarge.copyWith(
                            color: AppTheme.tertiaryText,
                          ),
                        ),
                        const SizedBox(height: AppTheme.spaceS),
                        Text(
                          'Add your first habit to get started',
                          style: AppTheme.bodyMedium,
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.only(
                      bottom: AppTheme.spaceXXL * 2,
                    ),
                    itemCount: _habits.length,
                    itemBuilder: (context, index) {
                      if (index >= _habits.length) {
                        return const SizedBox.shrink();
                      }

                      final habit = _habits[index];
                      return WeeklyHabitCard(
                        habit: habit,
                        weekStartDate: _currentWeekStart,
                        onCompletionChanged: (date) =>
                            _onHabitCompletionChanged(habit, date),
                        onFavoriteTapped: () => _onHabitFavorited(habit),
                        onDelete: () => _deleteHabit(habit),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddHabitSheet,
        backgroundColor: AppTheme.accentBlue,
        child: const Icon(Icons.add, color: AppTheme.primaryText, size: 28),
      ),
    );
  }
}

class AddHabitSheet extends StatefulWidget {
  final Function(String, TimeOfDay, Color, bool) onAdd;

  const AddHabitSheet({super.key, required this.onAdd});

  @override
  AddHabitSheetState createState() => AddHabitSheetState();
}

class AddHabitSheetState extends State<AddHabitSheet> {
  final _formKey = GlobalKey<FormState>();
  String _title = '';
  TimeOfDay _selectedTime = TimeOfDay.now();
  Color _selectedColor = AppTheme.accentBlue;
  int _targetCount = 1;
  bool _isFavorite = false;
  bool _isSubmitting = false;

  Future<void> _selectTime() async {
    if (!mounted) return;

    try {
      final TimeOfDay? picked = await showTimePicker(
        context: context,
        initialTime: _selectedTime,
        builder: (context, child) {
          return Theme(
            data: Theme.of(context).copyWith(
              timePickerTheme: TimePickerThemeData(
                backgroundColor: AppTheme.surfaceColor,
                hourMinuteTextColor: AppTheme.primaryText,
                dayPeriodTextColor: AppTheme.primaryText,
              ),
            ),
            child: child!,
          );
        },
      );

      if (picked != null && picked != _selectedTime && mounted) {
        setState(() {
          _selectedTime = picked;
        });
      }
    } catch (e) {
      debugPrint('Error selecting time: $e');
    }
  }

  void _submitForm() async {
    if (_isSubmitting || !mounted) return;

    if (_formKey.currentState!.validate()) {
      setState(() {
        _isSubmitting = true;
      });

      try {
        _formKey.currentState!.save();
        if (mounted) {
          widget.onAdd(_title, _selectedTime, _selectedColor, _isFavorite);
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _isSubmitting = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppTheme.radiusXL),
        ),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(top: AppTheme.spaceM),
            decoration: BoxDecoration(
              color: AppTheme.tertiaryText,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // Content
          Expanded(
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppTheme.spaceL),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Add New Habit', style: AppTheme.headlineMedium),
                    const SizedBox(height: AppTheme.spaceXL),

                    // Title field
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Habit Title',
                        hintText: 'e.g., Morning Workout',
                      ),
                      style: AppTheme.bodyLarge,
                      validator: (value) => value?.isEmpty == true
                          ? 'Please enter a title'
                          : null,
                      onSaved: (value) => _title = value ?? '',
                      enabled: !_isSubmitting,
                    ),
                    const SizedBox(height: AppTheme.spaceL),

                    // Time selection
                    Container(
                      decoration: BoxDecoration(
                        color: AppTheme.cardBackground,
                        borderRadius: BorderRadius.circular(AppTheme.radiusM),
                      ),
                      child: ListTile(
                        title: Text('Time', style: AppTheme.bodyLarge),
                        subtitle: Text(
                          _selectedTime.format(context),
                          style: AppTheme.bodyMedium.copyWith(
                            color: AppTheme.accentBlue,
                          ),
                        ),
                        trailing: const Icon(
                          Icons.access_time,
                          color: AppTheme.accentBlue,
                        ),
                        onTap: _isSubmitting ? null : _selectTime,
                      ),
                    ),
                    const SizedBox(height: AppTheme.spaceL),

                    // Target count
                    Container(
                      decoration: BoxDecoration(
                        color: AppTheme.cardBackground,
                        borderRadius: BorderRadius.circular(AppTheme.radiusM),
                      ),
                      child: ListTile(
                        title: Text('Daily Target', style: AppTheme.bodyLarge),
                        subtitle: Text(
                          '$_targetCount time${_targetCount > 1 ? 's' : ''} per day',
                          style: AppTheme.bodyMedium,
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.remove_circle_outline),
                              color: AppTheme.accentBlue,
                              onPressed: _isSubmitting || _targetCount <= 1
                                  ? null
                                  : () {
                                      if (mounted) {
                                        setState(() {
                                          _targetCount--;
                                        });
                                      }
                                    },
                            ),
                            Text(
                              '$_targetCount',
                              style: AppTheme.titleMedium.copyWith(
                                color: AppTheme.accentBlue,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.add_circle_outline),
                              color: AppTheme.accentBlue,
                              onPressed: _isSubmitting
                                  ? null
                                  : () {
                                      if (mounted) {
                                        setState(() {
                                          _targetCount++;
                                        });
                                      }
                                    },
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: AppTheme.spaceL),

                    // Color picker
                    Text('Choose Color', style: AppTheme.bodyLarge),
                    const SizedBox(height: AppTheme.spaceM),
                    if (!_isSubmitting)
                      Wrap(
                        spacing: AppTheme.spaceM,
                        runSpacing: AppTheme.spaceM,
                        children: AppTheme.habitColors.map((color) {
                          final isSelected = _selectedColor == color;
                          return GestureDetector(
                            onTap: () {
                              if (mounted) {
                                setState(() {
                                  _selectedColor = color;
                                });
                              }
                            },
                            child: Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: color,
                                shape: BoxShape.circle,
                                border: isSelected
                                    ? Border.all(
                                        color: AppTheme.primaryText,
                                        width: 3,
                                      )
                                    : null,
                              ),
                              child: isSelected
                                  ? const Icon(
                                      Icons.check,
                                      color: Colors.white,
                                      size: 24,
                                    )
                                  : null,
                            ),
                          );
                        }).toList(),
                      ),
                    const SizedBox(height: AppTheme.spaceL),

                    // Favorite toggle
                    Container(
                      decoration: BoxDecoration(
                        color: AppTheme.cardBackground,
                        borderRadius: BorderRadius.circular(AppTheme.radiusM),
                      ),
                      child: SwitchListTile(
                        title: Text(
                          'Mark as Favorite',
                          style: AppTheme.bodyLarge,
                        ),
                        subtitle: Text(
                          'Show star indicator for this habit',
                          style: AppTheme.bodyMedium,
                        ),
                        value: _isFavorite,
                        activeColor: Colors.amber,
                        onChanged: _isSubmitting
                            ? null
                            : (value) {
                                if (mounted) {
                                  setState(() {
                                    _isFavorite = value;
                                  });
                                }
                              },
                      ),
                    ),
                    const SizedBox(height: AppTheme.spaceXL),

                    // Submit button
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _isSubmitting ? null : _submitForm,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.accentBlue,
                          foregroundColor: AppTheme.primaryText,
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              AppTheme.radiusM,
                            ),
                          ),
                        ),
                        child: _isSubmitting
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    AppTheme.primaryText,
                                  ),
                                ),
                              )
                            : Text('Add Habit', style: AppTheme.titleMedium),
                      ),
                    ),
                    SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
