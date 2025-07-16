import 'package:flutter/material.dart';

class MessageInput extends StatelessWidget {
  final TextEditingController textController;
  final bool isLoading;
  final Function() onSend;
  final Function() onPickFile;
  final Function() onPickImage;
  final Function() onOcr;

  const MessageInput({
    super.key,
    required this.textController,
    required this.isLoading,
    required this.onSend,
    required this.onPickFile,
    required this.onPickImage,
    required this.onOcr,
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
          PopupMenuButton<int>(
            icon: const Icon(Icons.more_vert),
            tooltip: 'More actions',
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 0,
                child: ListTile(
                  leading: const Icon(Icons.attach_file),
                  title: const Text('Attach file'),
                ),
              ),
              PopupMenuItem(
                value: 1,
                child: ListTile(
                  leading: const Icon(Icons.image),
                  title: const Text('Attach image'),
                ),
              ),
              PopupMenuItem(
                value: 2,
                child: ListTile(
                  leading: const Icon(Icons.document_scanner),
                  title: const Text('OCR - Extract text from image'),
                ),
              ),
            ],
            onSelected: (value) {
              if (isLoading) return;
              if (value == 0) onPickFile();
              if (value == 1) onPickImage();
              if (value == 2) onOcr();
            },
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
