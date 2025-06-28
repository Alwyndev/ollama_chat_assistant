import 'package:flutter/material.dart';

class MessageInput extends StatelessWidget {
  final TextEditingController textController;
  final bool isLoading;
  final Function() onSend;
  final Function() onPickFile;
  final Function() onPickImage;

  const MessageInput({
    super.key,
    required this.textController,
    required this.isLoading,
    required this.onSend,
    required this.onPickFile,
    required this.onPickImage,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
          ),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.attach_file),
            onPressed: isLoading ? null : onPickFile,
            tooltip: 'Attach file',
          ),
          IconButton(
            icon: const Icon(Icons.image),
            onPressed: isLoading ? null : onPickImage,
            tooltip: 'Attach image',
          ),
          Expanded(
            child: TextField(
              controller: textController,
              decoration: InputDecoration(
                hintText: 'Type a message...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              onSubmitted: (_) => onSend(),
              minLines: 1,
              maxLines: 3,
            ),
          ),
          const SizedBox(width: 8),
          IconButton.filled(
            onPressed: isLoading ? null : onSend,
            icon: isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.send),
          ),
        ],
      ),
    );
  }
}
