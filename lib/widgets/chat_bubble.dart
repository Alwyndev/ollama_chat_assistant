import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/chat_message.dart';

class ChatBubble extends StatelessWidget {
  final ChatMessage message;
  final ColorScheme colorScheme;
  final bool isDarkMode;

  const ChatBubble({
    super.key,
    required this.message,
    required this.colorScheme,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    final backgroundColor = message.isUser
        ? colorScheme.primary
        : message.isSystem
        ? isDarkMode
              ? colorScheme.surfaceContainerHighest
              : colorScheme.secondaryContainer
        : message.isError
        ? colorScheme.errorContainer
        : isDarkMode
        ? colorScheme.surfaceContainerHighest
        : colorScheme.surface;

    final textColor = message.isUser
        ? colorScheme.onPrimary
        : message.isSystem
        ? isDarkMode
              ? colorScheme.onSurfaceVariant
              : colorScheme.onSecondaryContainer
        : message.isError
        ? colorScheme.onErrorContainer
        : colorScheme.onSurface;

    final borderRadius = message.isUser
        ? const BorderRadius.only(
            topLeft: Radius.circular(16),
            bottomLeft: Radius.circular(16),
            bottomRight: Radius.circular(16),
          )
        : const BorderRadius.only(
            topRight: Radius.circular(16),
            bottomLeft: Radius.circular(16),
            bottomRight: Radius.circular(16),
          );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        crossAxisAlignment: message.isUser
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: message.isUser
                ? MainAxisAlignment.end
                : MainAxisAlignment.start,
            children: [
              Flexible(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 600),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: backgroundColor,
                      borderRadius: borderRadius,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (!message.isUser)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 4),
                            child: Text(
                              message.isSystem
                                  ? "System"
                                  : message.isError
                                  ? "Error"
                                  : message.modelName ?? "Assistant",
                              style: TextStyle(
                                color: textColor.withValues(alpha: 0.8),
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        if (message.isFile)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                message.fileName ?? 'File',
                                style: TextStyle(
                                  color: textColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              if (message.mimeType?.startsWith('image/') ??
                                  false)
                                Container(
                                  height: 150,
                                  decoration: BoxDecoration(
                                    image: DecorationImage(
                                      image: MemoryImage(
                                        Uint8List.fromList(message.fileBytes!),
                                      ),
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                )
                              else
                                _buildFormattedText(
                                  message.text,
                                  textColor,
                                  context,
                                ),
                            ],
                          )
                        else
                          _buildFormattedText(message.text, textColor, context),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(top: 2, left: 8, right: 8),
            child: IconButton(
              icon: const Icon(Icons.copy, size: 18),
              tooltip: 'Copy',
              onPressed: () {
                Clipboard.setData(ClipboardData(text: message.text));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Message copied to clipboard')),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormattedText(
    String text,
    Color textColor,
    BuildContext context,
  ) {
    // Check if the text contains code blocks
    if (text.contains('```')) {
      return _buildTextWithCodeBlocks(text, textColor, context);
    }

    // Check for basic markdown formatting
    if (_containsMarkdown(text)) {
      return _buildMarkdownText(text, textColor, context);
    }

    // Regular text
    return SelectableText(text, style: TextStyle(color: textColor));
  }

  bool _containsMarkdown(String text) {
    return text.contains('**') ||
        text.contains('*') ||
        text.contains('`') ||
        text.contains('##') ||
        text.contains('###');
  }

  Widget _buildMarkdownText(
    String text,
    Color textColor,
    BuildContext context,
  ) {
    final spans = <TextSpan>[];
    final lines = text.split('\n');

    for (int i = 0; i < lines.length; i++) {
      final line = lines[i];

      if (line.startsWith('##')) {
        // H2 heading
        spans.add(
          TextSpan(
            text: line.substring(2).trim(),
            style: TextStyle(
              color: textColor,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        );
      } else if (line.startsWith('###')) {
        // H3 heading
        spans.add(
          TextSpan(
            text: line.substring(3).trim(),
            style: TextStyle(
              color: textColor,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        );
      } else if (line.startsWith('`') && line.endsWith('`')) {
        // Inline code
        spans.add(
          TextSpan(
            text: line.substring(1, line.length - 1),
            style: TextStyle(
              color: textColor,
              backgroundColor: isDarkMode ? Colors.grey[800] : Colors.grey[200],
              fontFamily: 'monospace',
            ),
          ),
        );
      } else {
        // Regular text with bold/italic formatting
        spans.add(_parseInlineFormatting(line, textColor));
      }

      if (i < lines.length - 1) {
        spans.add(const TextSpan(text: '\n'));
      }
    }

    return SelectableText.rich(TextSpan(children: spans));
  }

  TextSpan _parseInlineFormatting(String text, Color textColor) {
    final spans = <TextSpan>[];
    int currentIndex = 0;

    while (currentIndex < text.length) {
      // Find bold text (**text**)
      final boldMatch = RegExp(
        r'\*\*(.*?)\*\*',
      ).firstMatch(text.substring(currentIndex));
      if (boldMatch != null) {
        // Add text before bold
        if (boldMatch.start > 0) {
          spans.add(
            TextSpan(
              text: text.substring(
                currentIndex,
                currentIndex + boldMatch.start,
              ),
              style: TextStyle(color: textColor),
            ),
          );
        }
        // Add bold text
        spans.add(
          TextSpan(
            text: boldMatch.group(1),
            style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
          ),
        );
        currentIndex += boldMatch.end;
        continue;
      }

      // Find italic text (*text*)
      final italicMatch = RegExp(
        r'\*(.*?)\*',
      ).firstMatch(text.substring(currentIndex));
      if (italicMatch != null) {
        // Add text before italic
        if (italicMatch.start > 0) {
          spans.add(
            TextSpan(
              text: text.substring(
                currentIndex,
                currentIndex + italicMatch.start,
              ),
              style: TextStyle(color: textColor),
            ),
          );
        }
        // Add italic text
        spans.add(
          TextSpan(
            text: italicMatch.group(1),
            style: TextStyle(color: textColor, fontStyle: FontStyle.italic),
          ),
        );
        currentIndex += italicMatch.end;
        continue;
      }

      // Find inline code (`text`)
      final codeMatch = RegExp(
        r'`([^`]+)`',
      ).firstMatch(text.substring(currentIndex));
      if (codeMatch != null) {
        // Add text before code
        if (codeMatch.start > 0) {
          spans.add(
            TextSpan(
              text: text.substring(
                currentIndex,
                currentIndex + codeMatch.start,
              ),
              style: TextStyle(color: textColor),
            ),
          );
        }
        // Add code text
        spans.add(
          TextSpan(
            text: codeMatch.group(1),
            style: TextStyle(
              color: textColor,
              backgroundColor: isDarkMode ? Colors.grey[800] : Colors.grey[200],
              fontFamily: 'monospace',
            ),
          ),
        );
        currentIndex += codeMatch.end;
        continue;
      }

      // No more formatting found, add remaining text
      spans.add(
        TextSpan(
          text: text.substring(currentIndex),
          style: TextStyle(color: textColor),
        ),
      );
      break;
    }

    return TextSpan(children: spans);
  }

  Widget _buildTextWithCodeBlocks(
    String text,
    Color textColor,
    BuildContext context,
  ) {
    final parts = text.split(RegExp(r'```(\w+)?\n'));
    final widgets = <Widget>[];

    for (int i = 0; i < parts.length; i++) {
      if (i % 2 == 0) {
        // Regular text
        if (parts[i].isNotEmpty) {
          widgets.add(_buildMarkdownText(parts[i], textColor, context));
        }
      } else {
        // Code block
        final language = i > 0 ? parts[i - 1] : '';
        final code = parts[i];
        widgets.add(_buildCodeBlock(code, language, textColor, context));
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: widgets,
    );
  }

  Widget _buildCodeBlock(
    String code,
    String language,
    Color textColor,
    BuildContext context,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey[900] : Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isDarkMode ? Colors.grey[700]! : Colors.grey[300]!,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (language.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: isDarkMode ? Colors.grey[800] : Colors.grey[200],
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(8),
                  topRight: Radius.circular(8),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      language,
                      style: TextStyle(
                        color: textColor,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.copy, size: 16),
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: code));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Code copied to clipboard'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    },
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SelectableText(
                code,
                style: TextStyle(
                  color: textColor,
                  fontFamily: 'monospace',
                  fontSize: 13,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
