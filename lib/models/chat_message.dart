class ChatMessage {
  final String text;
  final bool isUser;
  final bool isSystem;
  final bool isError;
  final bool isFile;
  final String? modelName;
  final String? fileName;
  final List<int>? fileBytes;
  final String? mimeType;

  ChatMessage({
    required this.text,
    this.isUser = false,
    this.isSystem = false,
    this.isError = false,
    this.isFile = false,
    this.modelName,
    this.fileName,
    this.fileBytes,
    this.mimeType,
  });
}
