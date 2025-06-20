import 'package:flutter/material.dart';
import 'package:widget_habit_app/models/habit.dart';
import 'package:widget_habit_app/utils/app_theme.dart';

class WeeklyHabitCard extends StatelessWidget {
  final Habit habit;
  final DateTime weekStartDate;
  final Function(DateTime) onCompletionChanged;
  final VoidCallback onFavoriteTapped;
  final VoidCallback onDelete;

  const WeeklyHabitCard({
    super.key,
    required this.habit,
    required this.weekStartDate,
    required this.onCompletionChanged,
    required this.onFavoriteTapped,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppTheme.spaceM,
        vertical: AppTheme.spaceS,
      ),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(AppTheme.radiusM),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spaceM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with habit info and favorite star
            _buildHeader(context),
            const SizedBox(height: AppTheme.spaceM),
            // Weekly grid
            _buildWeeklyGrid(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        // Habit color indicator
        Container(
          width: 4,
          height: 40,
          decoration: BoxDecoration(
            color: habit.color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: AppTheme.spaceM),
        // Habit info
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                habit.title,
                style: AppTheme.titleMedium,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
              const SizedBox(height: AppTheme.spaceXS),
              Row(
                children: [
                  Icon(
                    Icons.access_time,
                    size: 14,
                    color: AppTheme.tertiaryText,
                  ),
                  const SizedBox(width: AppTheme.spaceXS),
                  Text(habit.time.format(context), style: AppTheme.bodySmall),
                  const SizedBox(width: AppTheme.spaceM),
                  Text(
                    '${habit.getWeekCompletedCount(weekStartDate)}/${habit.getWeekTotalCount()}',
                    style: AppTheme.bodySmall.copyWith(
                      color: habit.color,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        // Favorite and Delete buttons
        GestureDetector(
          onTap: onFavoriteTapped,
          child: Container(
            padding: const EdgeInsets.all(AppTheme.spaceS),
            child: Icon(
              habit.isFavorite ? Icons.star : Icons.star_border,
              color: habit.isFavorite ? Colors.amber : AppTheme.tertiaryText,
              size: 24,
            ),
          ),
        ),
        PopupMenuButton<String>(
          onSelected: (value) {
            if (value == 'delete') {
              onDelete();
            }
          },
          color: AppTheme.cardBackground,
          icon: const Icon(Icons.more_vert, color: AppTheme.tertiaryText),
          itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
            PopupMenuItem<String>(
              value: 'delete',
              child: Text('Delete Habit', style: AppTheme.bodyMedium),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildWeeklyGrid() {
    final today = DateTime.now();

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: List.generate(7, (index) {
        final date = weekStartDate.add(Duration(days: index));
        final status = habit.getCompletionStatus(date);
        final isToday = _isSameDay(date, today);
        final isFuture = date.isAfter(today) && !_isSameDay(date, today);

        return Column(
          children: [
            // Week day label
            Text(
              AppTheme.weekDays[index],
              style: isToday
                  ? AppTheme.bodySmall.copyWith(
                      fontWeight: FontWeight.w900,
                      color: AppTheme.currentDayHighlight,
                    )
                  : AppTheme.bodySmall,
            ),
            const SizedBox(height: AppTheme.spaceS),
            // Completion circle
            GestureDetector(
              onTap: isFuture ? null : () => onCompletionChanged(date),
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _getCompletionColor(status, isFuture),
                  border: isToday
                      ? Border.all(
                          color: AppTheme.currentDayHighlight,
                          width: 2,
                        )
                      : null,
                ),
                child: _getCompletionIcon(status, isFuture),
              ),
            ),
          ],
        );
      }),
    );
  }

  Color _getCompletionColor(CompletionStatus status, bool isFuture) {
    if (isFuture) {
      return AppTheme.cardBackground;
    }

    switch (status) {
      case CompletionStatus.completed:
        return AppTheme.completedGreen;
      case CompletionStatus.skipped:
        return AppTheme.accentOrange;
      case CompletionStatus.none:
        return AppTheme.incompleteGrey;
    }
  }

  Widget? _getCompletionIcon(CompletionStatus status, bool isFuture) {
    if (isFuture) return null;

    switch (status) {
      case CompletionStatus.completed:
        return const Icon(Icons.check, color: Colors.white, size: 16);
      case CompletionStatus.skipped:
        return const Icon(Icons.close, color: Colors.white, size: 16);
      case CompletionStatus.none:
        return null;
    }
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }
}
