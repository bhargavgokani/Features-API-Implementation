import 'package:flutter/material.dart';

class TodoInfoScreen extends StatelessWidget {
  const TodoInfoScreen(
      {super.key,
      required this.title,
      required this.userId,
      required this.completed});
  final int userId;
  final String title;
  final bool completed;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Todo Info.',
          style: TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(
            Icons.arrow_back_outlined,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF3F5769),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'User ID: $userId',
              style: const TextStyle(
                fontSize: 18,
                // fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Title: $title',
              style: const TextStyle(
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Completed: $completed',
              style: const TextStyle(
                fontSize: 18,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
