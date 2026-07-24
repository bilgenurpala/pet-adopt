import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../services/ai_service.dart';
import '../widgets/chat_message_bubble.dart';

class AiChatPage extends StatefulWidget {
  const AiChatPage({super.key});

  @override
  State<AiChatPage> createState() => _AiChatPageState();
}

class _AiChatPageState extends State<AiChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final ImagePicker _imagePicker = ImagePicker();

  final List<_ChatMessage> _messages = [
    const _ChatMessage(
      message: 'Hello! I can help you find a suitable pet for your lifestyle.',
      isUser: false,
    ),
  ];

  bool _isSending = false;

  Uint8List? _pendingImageBytes;
  String? _pendingImageMediaType;

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    if (_isSending) {
      return;
    }

    final picked = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1600,
      imageQuality: 85,
    );

    if (picked == null) {
      return;
    }

    final bytes = await picked.readAsBytes();
    final mediaType = _resolveMediaType(picked);

    if (mediaType == null) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unsupported image type. Use JPG, PNG, WEBP, or GIF.'),
        ),
      );
      return;
    }

    if (bytes.lengthInBytes > 5 * 1024 * 1024) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Image is larger than 5MB.')),
      );
      return;
    }

    setState(() {
      _pendingImageBytes = bytes;
      _pendingImageMediaType = mediaType;
    });
  }

  String? _resolveMediaType(XFile file) {
    final mimeType = file.mimeType;
    if (mimeType != null && _allowedMediaTypes.contains(mimeType)) {
      return mimeType;
    }

    final name = file.name.toLowerCase();
    if (name.endsWith('.jpg') || name.endsWith('.jpeg')) return 'image/jpeg';
    if (name.endsWith('.png')) return 'image/png';
    if (name.endsWith('.webp')) return 'image/webp';
    if (name.endsWith('.gif')) return 'image/gif';

    return null;
  }

  static const _allowedMediaTypes = {
    'image/jpeg',
    'image/png',
    'image/webp',
    'image/gif',
  };

  void _removePendingImage() {
    setState(() {
      _pendingImageBytes = null;
      _pendingImageMediaType = null;
    });
  }

  Future<void> _sendMessage() async {
    final message = _messageController.text.trim();
    final hasImage = _pendingImageBytes != null;

    if ((message.isEmpty && !hasImage) || _isSending) {
      return;
    }

    FocusScope.of(context).unfocus();

    final imageBytes = _pendingImageBytes;
    final imageMediaType = _pendingImageMediaType;

    setState(() {
      _messages.add(
        _ChatMessage(
          message: message,
          isUser: true,
          imageBytes: imageBytes,
          imageMediaType: imageMediaType,
        ),
      );
      _isSending = true;
      _pendingImageBytes = null;
      _pendingImageMediaType = null;
    });

    _messageController.clear();
    _scrollToBottom();

    try {
      final response = await AIService.sendMessage(
        messages: _messages.map((chatMessage) {
          final payload = <String, dynamic>{
            'role': chatMessage.isUser ? 'user' : 'assistant',
            'content': chatMessage.message,
          };

          if (chatMessage.imageBytes != null &&
              chatMessage.imageMediaType != null) {
            payload['image'] = {
              'media_type': chatMessage.imageMediaType,
              'data': base64Encode(chatMessage.imageBytes!),
            };
          }

          return payload;
        }).toList(),
      );

      final reply = response['reply']?.toString().trim();

      if (!mounted) {
        return;
      }

      setState(() {
        _messages.add(
          _ChatMessage(
            message: reply == null || reply.isEmpty
                ? 'I could not generate a response. Please try again.'
                : reply,
            isUser: false,
          ),
        );
      });
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _messages.add(
          _ChatMessage(message: _getErrorMessage(error), isUser: false),
        );
      });
    } finally {
      if (mounted) {
        setState(() {
          _isSending = false;
        });

        _scrollToBottom();
      }
    }
  }

  String _getErrorMessage(Object error) {
    final message = error.toString();

    if (message.contains('Connection refused') ||
        message.contains('Failed host lookup') ||
        message.contains('XMLHttpRequest error')) {
      return 'AI service is unavailable. Make sure it is running on port 8001.';
    }

    return 'The AI assistant could not respond. Please try again.';
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) {
        return;
      }

      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('AI Assistant'), centerTitle: true),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(16),
                itemCount: _messages.length + (_isSending ? 1 : 0),
                itemBuilder: (context, index) {
                  if (_isSending && index == _messages.length) {
                    return const _TypingIndicator();
                  }

                  final message = _messages[index];

                  return ChatMessageBubble(
                    message: message.message,
                    isUser: message.isUser,
                    imageBytes: message.imageBytes,
                  );
                },
              ),
            ),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                border: Border(top: BorderSide(color: Colors.grey.shade300)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_pendingImageBytes != null) ...[
                    Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.memory(
                            _pendingImageBytes!,
                            height: 80,
                            width: 80,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Positioned(
                          top: -8,
                          right: -8,
                          child: IconButton(
                            onPressed: _removePendingImage,
                            icon: const Icon(Icons.cancel, size: 20),
                            style: IconButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: Colors.black87,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                  ],
                  Row(
                    children: [
                      IconButton(
                        onPressed: _isSending ? null : _pickImage,
                        tooltip: 'Attach an image',
                        icon: const Icon(Icons.image_outlined),
                      ),
                      Expanded(
                        child: TextField(
                          controller: _messageController,
                          enabled: !_isSending,
                          minLines: 1,
                          maxLines: 4,
                          textInputAction: TextInputAction.send,
                          onSubmitted: (_) => _sendMessage(),
                          decoration: InputDecoration(
                            hintText: _isSending
                                ? 'AI is responding...'
                                : 'Ask anything...',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      IconButton.filled(
                        onPressed: _isSending ? null : _sendMessage,
                        style: IconButton.styleFrom(
                          backgroundColor: const Color(0xFFD4A017),
                          foregroundColor: Colors.white,
                          disabledBackgroundColor: Colors.grey.shade300,
                        ),
                        icon: _isSending
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(Icons.send),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChatMessage {
  const _ChatMessage({
    required this.message,
    required this.isUser,
    this.imageBytes,
    this.imageMediaType,
  });

  final String message;
  final bool isUser;
  final Uint8List? imageBytes;
  final String? imageMediaType;
}

class _TypingIndicator extends StatelessWidget {
  const _TypingIndicator();

  @override
  Widget build(BuildContext context) {
    return const Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: EdgeInsets.only(bottom: 12),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: Color(0xFFF1F1F1),
            borderRadius: BorderRadius.all(Radius.circular(16)),
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
        ),
      ),
    );
  }
}
