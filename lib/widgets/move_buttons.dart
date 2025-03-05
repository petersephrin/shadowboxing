import 'package:flutter/material.dart';
import '../game_screen.dart';

class MoveButtons extends StatelessWidget {
  final Function(Move) onMoveSelected;

  const MoveButtons({Key? key, required this.onMoveSelected}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Up button
        Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: _buildMoveButton(
            icon: Icons.arrow_upward,
            label: "UP",
            color: Colors.blue,
            onPressed: () => onMoveSelected(Move.up),
          ),
        ),
        // Left, Right buttons in a row
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildMoveButton(
              icon: Icons.arrow_back,
              label: "LEFT",
              color: Colors.green,
              onPressed: () => onMoveSelected(Move.left),
            ),
            SizedBox(width: 24),
            _buildMoveButton(
              icon: Icons.arrow_forward,
              label: "RIGHT",
              color: Colors.red,
              onPressed: () => onMoveSelected(Move.right),
            ),
          ],
        ),
        // Down button
        Padding(
          padding: const EdgeInsets.only(top: 16.0),
          child: _buildMoveButton(
            icon: Icons.arrow_downward,
            label: "DOWN",
            color: Colors.orange,
            onPressed: () => onMoveSelected(Move.down),
          ),
        ),
      ],
    );
  }

  Widget _buildMoveButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 24),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        textStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
