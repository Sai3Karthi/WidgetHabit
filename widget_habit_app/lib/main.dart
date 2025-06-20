import 'package:flutter/material.dart';
import 'package:widget_habit_app/widgets/habit_card.dart';
import 'package:widget_habit_app/widgets/weekly_date_picker.dart';
import 'package:widget_habit_app/models/habit.dart'; // Import Habit model
import 'package:widget_habit_app/services/habit_service.dart'; // Import HabitService
import 'package:widget_habit_app/screens/add_habit_screen.dart'; // Import AddHabitScreen

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Widget Habit',
      theme: ThemeData(
        // We will customize this later for themes, transparency, and individual colors.
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.grey[900]!,
          primary: Colors.grey[800],
          secondary: Colors.grey[700],
          surface: Colors.grey[900],
          onSurface: Colors.white,
          onPrimary: Colors.white,
          onSecondary: Colors.white,
        ),
        cardColor: Colors.grey[850], // Darker grey for cards
        scaffoldBackgroundColor: Colors.grey[900], // Dark background color
        useMaterial3: true,
        textTheme: const TextTheme(
          displaySmall: TextStyle(
            color: Colors.white,
          ), // Ensure text remains visible
          headlineSmall: TextStyle(color: Colors.white),
          titleLarge: TextStyle(color: Colors.white),
          titleMedium: TextStyle(color: Colors.white70),
          bodyMedium: TextStyle(color: Colors.white70),
          bodySmall: TextStyle(color: Colors.black), // For calendar day number
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.grey[900],
          foregroundColor: Colors.white, // For icon buttons and title
        ),
      ),
      home: const GoalsScreen(), // Our main screen will be GoalsScreen
    );
  }
}

class GoalsScreen extends StatefulWidget {
  const GoalsScreen({super.key});

  @override
  State<GoalsScreen> createState() => _GoalsScreenState();
}

class _GoalsScreenState extends State<GoalsScreen> {
  late DateTime _currentWeekStart;
  late DateTime _selectedDay;
  final HabitService _habitService = HabitService(); // Initialize HabitService
  List<Habit> _habits = []; // List to hold loaded habits

  @override
  void initState() {
    super.initState();
    _selectedDay = DateTime.now();
    _currentWeekStart = _findStartOfWeek(_selectedDay);
    _loadHabits(); // Load habits when the screen initializes
  }

  Future<void> _loadHabits() async {
    _habits = await _habitService.loadHabits();
    if (_habits.isEmpty) {
      // Add some dummy habits if none exist
      _habits.add(
        Habit(
          title: 'Banana -3',
          time: TimeOfDay.now(),
          color: Colors.red,
          targetCount: 43,
        ),
      );
      _habits.add(
        Habit(
          title: 'Hostel booking for eggs and',
          time: TimeOfDay.now(),
          color: Colors.blueAccent,
          targetCount: 5,
        ),
      );
      _habits.add(
        Habit(
          title: 'Egg -> 1 full egg + 2 whites',
          time: TimeOfDay.now(),
          color: Colors.orange,
          targetCount: 43,
        ),
      );
      _habits.add(
        Habit(
          title: 'Protien powder',
          time: TimeOfDay.now(),
          color: Colors.green,
          targetCount: 43,
        ),
      );
      _habits.add(
        Habit(
          title: 'Dry fruits -> cashews pistas',
          time: TimeOfDay.now(),
          color: Colors.purple,
          targetCount: 43,
        ),
      );
      _habits.add(
        Habit(
          title: 'Gym',
          time: TimeOfDay.fromDateTime(
            DateTime.now().add(const Duration(hours: 1)),
          ),
          color: Colors.grey,
          targetCount: 43,
        ),
      ); // Added Gym habit
      await _habitService.saveHabits(_habits);
    }
    setState(() {}); // Rebuild the UI with loaded habits
  }

  DateTime _findStartOfWeek(DateTime date) {
    int daysToSubtract =
        date.weekday - 1; // Assuming Monday is the first day of the week
    return DateTime(date.year, date.month, date.day - daysToSubtract);
  }

  void _onWeekChanged(DateTime newWeekStart) {
    setState(() {
      _currentWeekStart = newWeekStart;
      // Optionally, adjust selectedDay if it falls outside the new week
      if (!_isDayInWeek(_selectedDay, _currentWeekStart)) {
        _selectedDay =
            _currentWeekStart; // Default to the first day of the new week
      }
    });
  }

  void _onDaySelected(DateTime day) {
    setState(() {
      _selectedDay = day;
    });
  }

  bool _isDayInWeek(DateTime day, DateTime weekStart) {
    return day.isAfter(weekStart.subtract(const Duration(days: 1))) &&
        day.isBefore(weekStart.add(const Duration(days: 7)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900], // Dark background color
      appBar: AppBar(
        backgroundColor: Colors.grey[900],
        leading: Builder(
          builder: (BuildContext context) {
            return IconButton(
              icon: const Icon(Icons.menu, color: Colors.white),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            );
          },
        ),
        title: Text(
          'Week view',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: false,
        actions: [
          IconButton(
            icon: Stack(
              alignment: Alignment.center,
              children: [
                const Icon(
                  Icons.calendar_today,
                  color: Colors.white70,
                  size: 28,
                ),
                Positioned(
                  top: 8,
                  child: Text(
                    '${_selectedDay.day}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            onPressed: () {
              // Handle calendar icon tap - perhaps open a full calendar view
            },
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.menu, color: Colors.white),
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              WeeklyDatePicker(
                currentWeekStart: _currentWeekStart,
                selectedDay: _selectedDay,
                onWeekChanged: _onWeekChanged,
                onDaySelected: _onDaySelected,
                habits: _habits, // Pass the list of habits
              ),
              const SizedBox(height: 20),
              Expanded(
                child: ListView.builder(
                  itemCount: _habits.length,
                  itemBuilder: (context, index) {
                    final habit = _habits[index];
                    return HabitCard(
                      habit: habit, // Pass the Habit object directly
                      cardColor: Colors.blue, // Example color
                      opacity: 0.7,
                      currentWeekStart: _currentWeekStart,
                      selectedDay: _selectedDay,
                      onDayToggled: (data) async {
                        final String habitTitle = data['habitTitle'];
                        final DateTime date = data['date'];
                        final CompletionStatus status = data['status'];
                        await _habitService.updateHabitCompletion(
                          habitTitle,
                          date,
                          status,
                        );
                        _loadHabits(); // Reload habits to update UI
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddHabitScreen()),
          );
          if (result == true) {
            _loadHabits(); // Reload habits if a new one was added
          }
        },
        backgroundColor: Colors.redAccent,
        child: const Icon(Icons.add, color: Colors.white, size: 36),
      ),
      drawer: Drawer(
        backgroundColor: Colors.grey[850], // Darker background for the drawer
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color:
                    Colors.grey[800], // Slightly lighter than drawer background
              ),
              child: const Text(
                'Menu',
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home, color: Colors.white70),
              title: const Text('Home', style: TextStyle(color: Colors.white)),
              onTap: () {
                // Handle navigation to Home
                Navigator.pop(context); // Close the drawer
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings, color: Colors.white70),
              title: const Text(
                'Settings',
                style: TextStyle(color: Colors.white),
              ),
              onTap: () {
                // Handle navigation to Settings
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.info, color: Colors.white70),
              title: const Text('About', style: TextStyle(color: Colors.white)),
              onTap: () {
                // Handle navigation to About
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}
