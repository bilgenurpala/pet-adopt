import 'package:flutter/material.dart';

class AiChatPage extends StatelessWidget {
  const AiChatPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('AI Assistant'), centerTitle: true),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 24),

            const CircleAvatar(
              radius: 36,
              backgroundColor: Color(0xFFD4A017),
              child: Icon(Icons.pets, color: Colors.white, size: 34),
            ),

            const SizedBox(height: 16),

            Text('Hello 👋', style: Theme.of(context).textTheme.headlineSmall),

            const SizedBox(height: 8),

            const Text(
              'I can help you find the perfect pet.\nAsk me anything!',
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 24),

            const Expanded(
              child: Center(
                child: Text(
                  'No messages yet',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Ask anything...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 12),

                  FilledButton(onPressed: () {}, child: const Icon(Icons.send)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
