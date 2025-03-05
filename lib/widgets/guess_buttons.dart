import 'package:flutter/material.dart';
import '../game_screen.dart';

class GuessButtons extends StatelessWidget {
  final Function(Move) onGuessSelected;
  final bool enabled;

  const GuessButtons({
    Key? key,
    required this.onGuessSelected,
    this.enabled = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Up button
        Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: _buildGuessButton(
            icon: Icons.arrow_upward,
            label: "UP",
            color: Colors.blue,
            onPressed: enabled ? () => onGuessSelected(Move.up) : null,
          ),
        ),
        // Left, Right buttons in a row
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildGuessButton(
              icon: Icons.arrow_back,
              label: "LEFT",
              color: Colors.green,
              onPressed: enabled ? () => onGuessSelected(Move.left) : null,
            ),
            SizedBox(width: 24),
            _buildGuessButton(
              icon: Icons.arrow_forward,
              label: "RIGHT",
              color: Colors.red,
              onPressed: enabled ? () => onGuessSelected(Move.right) : null,
            ),
          ],
        ),
        // Down button
        Padding(
          padding: const EdgeInsets.only(top: 16.0),
          child: _buildGuessButton(
            icon: Icons.arrow_downward,
            label: "DOWN",
            color: Colors.orange,
            onPressed: enabled ? () => onGuessSelected(Move.down) : null,
          ),
        ),
      ],
    );
  }

  Widget _buildGuessButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback? onPressed,
  }) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 24),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: onPressed == null ? Colors.grey : color,
        foregroundColor: Colors.white,
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        textStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
