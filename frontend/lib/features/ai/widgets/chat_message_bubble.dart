import 'dart:typed_data';

import 'package:flutter/material.dart';

class ChatMessageBubble extends StatelessWidget {
  const ChatMessageBubble({
    required this.message,
    required this.isUser,
    this.imageBytes,
    super.key,
  });

  final String message;
  final bool isUser;
  final Uint8List? imageBytes;

  @override
  Widget build(BuildContext context) {
    final bubbleColor = isUser ? const Color(0xFFD4A017) : Colors.grey.shade200;

    final textColor = isUser ? Colors.white : Colors.black87;

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.all(8),
        constraints: const BoxConstraints(maxWidth: 300),
        decoration: BoxDecoration(
          color: bubbleColor,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(18),
            topRight: const Radius.circular(18),
            bottomLeft: Radius.circular(isUser ? 18 : 4),
            bottomRight: Radius.circular(isUser ? 4 : 18),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (imageBytes != null) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.memory(
                  imageBytes!,
                  fit: BoxFit.cover,
                  height: 160,
                ),
              ),
              if (message.isNotEmpty) const SizedBox(height: 8),
            ],
            if (message.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Text(
                  message,
                  style: TextStyle(color: textColor, fontSize: 15),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
