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
              initialDate: DateTime.now().subtract(const Duration(days: 365 * 25)),
              firstDate: DateTime(1900),
              lastDate: DateTime.now(),
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
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _selectedDate == null
              ? null
              : () => Navigator.pop(context, _selectedDate),
          child: const Text('Verify Age'),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.month}/${date.day}/${date.year}';
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
  final Function(DateTime) onChanged;

  @override
  State<DatePickerWidget> createState() => _DatePickerWidgetState();
}

class _DatePickerWidgetState extends State<DatePickerWidget> {
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.initialDate;
  }

  @override
  Widget build(BuildContext context) {
    return DatePicker(
      initialDate: _selectedDate,
      firstDate: widget.firstDate,
      lastDate: widget.lastDate,
      onChangeEnd: (date, __) {
        setState(() {
          _selectedDate = date;
        });
        widget.onChanged(date);
      },
    );
  }
}
