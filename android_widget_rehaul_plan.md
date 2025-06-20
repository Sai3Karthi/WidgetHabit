# Android Widget Rehaul Plan for WidgetHabit

## 1. Widget Data Model & Sync
- **Define a minimal, robust data model** for widget display (habit title, color, week completion, favorite, etc.).
- **Use SharedPreferences** for data sync from Flutter to Android (key: `flutter.widget_habit_data`).
- **Flutter side:**
  - Serialize only the data needed for the widget (avoid large/complex objects).
  - Write to SharedPreferences using `shared_preferences` plugin.
  - Trigger widget update via `MethodChannel` after any habit change.
- **Android side:**
  - Always read from SharedPreferences in the widget provider.
  - Handle missing/corrupt data gracefully (show error/empty state).

## 2. Widget Provider (Kotlin)
- **Stateless, robust AppWidgetProvider** implementation in Kotlin.
- **onUpdate:**
  - Always render from current SharedPreferences data.
  - If data is missing/corrupt, show a clear error/empty state.
- **No legacy/unused code.**
- **Debug logging** for all major steps (data load, render, error).
- **Handle user interaction:**
  - Tapping a habit row opens the app to that habit.
  - Tapping a completion dot toggles completion (via broadcast/intent to MainActivity).

## 3. Widget Layouts (XML)
- **One main layout** for the widget (medium size, vertical list of habits, header, progress summary).
- **One row layout** for each habit (title, color, week grid, favorite star).
- **Error/empty state view** in the main layout.
- **Use only essential views/IDs.**
- **Dark theme, modern look.**

## 4. Flutter Integration
- **WidgetService.dart**:
  - Handles serialization and writing of widget data to SharedPreferences.
  - Triggers widget update via `MethodChannel`.
- **main.dart**:
  - Calls WidgetService after any habit change.
  - Handles incoming intents from widget (if needed).

## 5. Gradle & Kotlin Integration
- **Ensure build.gradle (KTS) is up to date** for Kotlin and Flutter v2 embedding.
- **Kotlin code in `android/app/src/main/kotlin/...`**
- **All resources in `android/app/src/main/res/`**
- **Manifest properly registers widget provider and permissions.**

## 6. Testing & Debugging
- **Test with no data, partial data, and full data.**
- **Add debug logs for every major step.**
- **Check widget on device for correct display and interactivity.**

---

**All implementation steps will reference this plan.** 