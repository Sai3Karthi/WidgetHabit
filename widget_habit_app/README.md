# WidgetHabit App

A Flutter application for tracking daily habits with an Android home screen widget.

## Features

- Create and manage daily habits
- Track habit completion status (completed, skipped, or not done)
- Weekly calendar view to see your progress
- Android home screen widget for quick habit tracking

## Getting Started

### Prerequisites

- Flutter SDK (latest stable version)
- Android SDK (for Android development)

### Installation

1. Clone the repository:
   ```
   git clone https://github.com/yourusername/widget_habit_app.git
   ```

2. Navigate to the project directory:
   ```
   cd widget_habit_app
   ```

3. Install dependencies:
   ```
   flutter pub get
   ```

4. Run the app:
   ```
   flutter run
   ```

## Android Widget Setup

The app includes an Android home screen widget that displays your habits for the day. To add the widget:

1. Long-press on your Android home screen
2. Select "Widgets"
3. Find "WidgetHabit" in the list
4. Drag and drop it onto your home screen

## Project Structure

- `lib/models/` - Data models
- `lib/services/` - Business logic and data services
- `lib/widgets/` - Reusable UI components
- `android/app/src/main/kotlin/` - Android-specific code for the home screen widget

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License - see the LICENSE file for details.
