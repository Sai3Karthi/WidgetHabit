import 'package:flutter/material.dart';
import 'package:widget_habit_app/widgets/habit_card.dart';
import 'package:widget_habit_app/widgets/weekly_date_picker.dart';

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
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const GoalsScreen(), // Our main screen will be GoalsScreen
    );
  }
}

class GoalsScreen extends StatelessWidget {
  const GoalsScreen({super.key});

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
          'Goals',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: false, // Align title to the left
        actions: [
          Text(
            'THU',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(color: Colors.white70),
          ),
          Text(
            ' 19 Jun',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 16), // Add some spacing to the right
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const WeeklyDatePicker(),
            const SizedBox(height: 20),
            Expanded(
              child: ListView(
                children: const [
                  HabitCard(
                    title: 'Banana -3',
                    time: '7:30 pm',
                    progress: '3/43',
                    cardColor: Colors.red,
                    opacity: 0.7,
                  ),
                  HabitCard(
                    title: 'Hostel booking for eggs and',
                    time: '11:00 am',
                    progress: '0/5',
                    cardColor: Colors.blueAccent,
                    opacity: 0.7,
                  ),
                  HabitCard(
                    title: 'Egg -> 1 full egg + 2 whites',
                    time: '11:00 am',
                    progress: '5/43',
                    cardColor: Colors.orange,
                    opacity: 0.7,
                  ),
                  HabitCard(
                    title: 'Protien powder',
                    time: '6:30 pm',
                    progress: '4/43',
                    cardColor: Colors.green,
                    opacity: 0.7,
                  ),
                  HabitCard(
                    title: 'Dry fruits -> cashews pistas',
                    time: '11:00 am',
                    progress: '5/43',
                    cardColor: Colors.purple,
                    opacity: 0.7,
                  ),
                ],
              ),
            ),
          ],
        ),
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
