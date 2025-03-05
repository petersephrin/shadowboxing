import 'package:flutter/material.dart';

class Scoreboard extends StatelessWidget {
  final int correctStreak;

  const Scoreboard({Key? key, required this.correctStreak}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 16, horizontal: 32),
      decoration: BoxDecoration(
        color: Colors.black38,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: correctStreak > 0 ? Colors.amber : Colors.white30,
          width: 2,
        ),
      ),
      child: Column(
        children: [
          Text(
            "STREAK",
            style: TextStyle(
              color: Colors.white70,
              fontSize: 18,
              fontWeight: FontWeight.bold,
              letterSpacing: 2.0,
            ),
          ),
          SizedBox(height: 8),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(3, (index) {
              final isActive = index < correctStreak;
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: _buildStreak(isActive),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildStreak(bool isActive) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        color: isActive ? Colors.amber : Colors.white24,
        shape: BoxShape.circle,
        boxShadow:
            isActive
                ? [
                  BoxShadow(
                    color: Colors.amber.withOpacity(0.6),
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ]
                : [],
      ),
    );
  }
}
