import 'package:flutter/material.dart';

/// A dialog that enforces a strict 18+ age requirement.
///
/// This dialog is displayed during sign-up and requires users
/// to confirm they are 18 years or older before proceeding.
class AgeGateDialog extends StatefulWidget {
  /// Creates an [AgeGateDialog].
  const AgeGateDialog({super.key});

  @override
  State<AgeGateDialog> createState() => _AgeGateDialogState();
}

class _AgeGateDialogState extends State<AgeGateDialog> {
  DateTime? _selectedDate;
  String? _error;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Age Verification'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'This application is intended for users 18 years of age or older. '
              'Please verify your age to continue.',
            ),
            const SizedBox(height: 24),
            DatePickerWidget(
              initialDate: DateUtils.dateOnly(DateTime.now().subtract(const Duration(days: 365 * 25))),
              firstDate: DateTime(1900),
              lastDate: DateUtils.dateOnly(DateTime.now()),
              onChanged: (date) {
                setState(() {
                  _selectedDate = date;
                });
              },
            ),
            if (_selectedDate != null) ...[
              const SizedBox(height: 16),
              Text(
                'You selected: ${_formatDate(_selectedDate!)}',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
            if (_error != null) ...[
              const SizedBox(height: 16),
              Text(
                _error!,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.error,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, null),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _selectedDate == null
              ? null
              : () {
                  if (is18Plus(_selectedDate!)) {
                    Navigator.pop(context, _selectedDate);
                  } else {
                    setState(() {
                      _error = 'You must be 18 years or older to use this application.';
                    });
                  }
                },
          child: const Text('Verify Age'),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.month.toString().padLeft(2, '0')}/${date.day.toString().padLeft(2, '0')}/${date.year}';
  }
}

/// A date picker widget that allows users to select their date of birth.
class DatePickerWidget extends StatefulWidget {
  /// Creates a [DatePickerWidget].
  const DatePickerWidget({
    super.key,
    required this.initialDate,
    required this.firstDate,
    required this.lastDate,
    required this.onChanged,
  });

  /// The initial date to display.
  final DateTime initialDate;

  /// The earliest selectable date.
  final DateTime firstDate;

  /// The latest selectable date.
  final DateTime lastDate;

  /// Callback when the date changes.
  final ValueChanged<DateTime> onChanged;

  @override
  State<DatePickerWidget> createState() => _DatePickerWidgetState();
}

class _DatePickerWidgetState extends State<DatePickerWidget> {
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.initialDate;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.onChanged(_selectedDate);
    });
  }

  @override
  Widget build(BuildContext context) {
    return CalendarDatePicker(
      initialDate: _selectedDate,
      firstDate: widget.firstDate,
      lastDate: widget.lastDate,
      onDateChanged: (date) {
        setState(() {
          _selectedDate = date;
        });
        widget.onChanged(date);
      },
    );
  }
}

/// Checks if the given date of birth corresponds to a user who is 18 years or older.
bool is18Plus(DateTime dateOfBirth) {
  final now = DateTime.now();
  final age = now.year - dateOfBirth.year -
      (now.month < dateOfBirth.month || (now.month == dateOfBirth.month && now.day < dateOfBirth.day) ? 1 : 0);
  return age >= 18;
}
