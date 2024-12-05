import 'package:flutter/material.dart';

class ReminderToggle extends StatefulWidget {
  @override
  _ReminderToggleState createState() => _ReminderToggleState();
}

class _ReminderToggleState extends State<ReminderToggle> {
  bool _isReminderEnabled = false; // Tracks the state of the switch

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      // crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          "Remind me next time",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Color(0xFF3F5769), // Adjust color to make it noticeable
          ),
        ),
        Switch(
          value: _isReminderEnabled,
          onChanged: (value) {
            setState(() {
              _isReminderEnabled = value; // Toggles the switch state
            });
          },
          activeColor: Colors.white,
          activeTrackColor:
              Color(0xFF1D3548), // Color when the switch is active
          // inactiveThumbColor: Colors.grey, // Thumb color when inactive
          inactiveTrackColor: Colors.white, // Track color when inactive
        ),
      ],
    );
  }
}
