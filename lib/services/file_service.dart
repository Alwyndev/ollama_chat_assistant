import 'dart:typed_data';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:image/image.dart' as img;
import 'package:mime/mime.dart';
import 'ocr_service.dart';

class FileService {
  final OcrService _ocrService = OcrService();

  /// Extracts text from various file types
  /// Supports: PDF, TXT, code files, images, and other text-based formats
  Future<String> extractTextFromFile(
    List<int> fileBytes,
    String fileName,
    String? mimeType,
  ) async {
    try {
      // Validate inputs
      if (fileBytes.isEmpty) {
        return 'Error: File is empty or could not be read.';
      }

      if (fileName.isEmpty) {
        return 'Error: Invalid file name.';
      }

      final mime = mimeType ?? lookupMimeType(fileName) ?? '';
      final extension = _getFileExtension(fileName).toLowerCase();

      if (mime.startsWith('application/pdf')) {
        return await _extractTextFromPdf(fileBytes);
      } else if (mime.startsWith('text/') || _isTextFile(extension)) {
        return await _extractTextFromTextFile(fileBytes, fileName);
      } else if (mime.startsWith('image/')) {
        return await _extractTextFromImage(fileBytes);
      } else {
        // Try to extract as text for unknown file types
        return await _extractTextFromTextFile(fileBytes, fileName);
      }
    } catch (e) {
      return 'Error extracting text: $e';
    }
  }

  String _getFileExtension(String fileName) {
    final parts = fileName.split('.');
    return parts.length > 1 ? parts.last : '';
  }

  bool _isTextFile(String extension) {
    const textExtensions = {
      'txt',
      'md',
      'json',
      'xml',
      'html',
      'htm',
      'css',
      'js',
      'ts',
      'jsx',
      'tsx',
      'py',
      'java',
      'cpp',
      'c',
      'cs',
      'php',
      'rb',
      'go',
      'rs',
      'swift',
      'kt',
      'dart',
      'scala',
      'r',
      'sql',
      'sh',
      'bat',
      'ps1',
      'yaml',
      'yml',
      'toml',
      'ini',
      'cfg',
      'conf',
      'log',
      'csv',
      'tsv',
      'tex',
      'rst',
      'adoc',
    };
    return textExtensions.contains(extension);
  }

  Future<String> _extractTextFromPdf(List<int> fileBytes) async {
    try {
      if (fileBytes.isEmpty) {
        return 'Error: PDF file is empty.';
      }

      final PdfDocument document = PdfDocument(
        inputBytes: Uint8List.fromList(fileBytes),
      );
      final String text = PdfTextExtractor(document).extractText();
      document.dispose();

      if (text.isEmpty) {
        return 'No text found in PDF. The PDF might be image-based or scanned.';
      }

      return text;
    } catch (e) {
      return 'Error extracting text from PDF: $e';
    }
  }

  Future<String> _extractTextFromTextFile(
    List<int> fileBytes,
    String fileName,
  ) async {
    try {
      final String text = String.fromCharCodes(fileBytes);
      if (text.isEmpty) {
        return 'Empty file: $fileName';
      }

      final extension = _getFileExtension(fileName).toLowerCase();
      final isCodeFile = _isCodeFile(extension);

      if (isCodeFile) {
        return '```${_getLanguageFromExtension(extension)}\n$text\n```';
      } else {
        return text;
      }
    } catch (e) {
      return 'Error reading file: $e';
    }
  }

  bool _isCodeFile(String extension) {
    const codeExtensions = {
      'py',
      'java',
      'cpp',
      'c',
      'cs',
      'php',
      'rb',
      'go',
      'rs',
      'swift',
      'kt',
      'dart',
      'scala',
      'r',
      'sql',
      'js',
      'ts',
      'jsx',
      'tsx',
      'html',
      'css',
      'xml',
      'json',
      'yaml',
      'yml',
      'toml',
      'sh',
      'bat',
      'ps1',
      'md',
    };
    return codeExtensions.contains(extension);
  }

  String _getLanguageFromExtension(String extension) {
    const languageMap = {
      'py': 'python',
      'java': 'java',
      'cpp': 'cpp',
      'c': 'c',
      'cs': 'csharp',
      'php': 'php',
      'rb': 'ruby',
      'go': 'go',
      'rs': 'rust',
      'swift': 'swift',
      'kt': 'kotlin',
      'dart': 'dart',
      'scala': 'scala',
      'r': 'r',
      'sql': 'sql',
      'js': 'javascript',
      'ts': 'typescript',
      'jsx': 'jsx',
      'tsx': 'tsx',
      'html': 'html',
      'css': 'css',
      'xml': 'xml',
      'json': 'json',
      'yaml': 'yaml',
      'yml': 'yaml',
      'toml': 'toml',
      'sh': 'bash',
      'bat': 'batch',
      'ps1': 'powershell',
      'md': 'markdown',
    };
    return languageMap[extension] ?? extension;
  }

  Future<String> _extractTextFromImage(List<int> fileBytes) async {
    try {
      // Use OCR service to extract text from image
      final extractedText = await _ocrService.extractTextFromImage(fileBytes);

      if (extractedText.startsWith('Error:') ||
          extractedText.startsWith('No text found')) {
        // If OCR fails or no text found, provide fallback information
        final image = img.decodeImage(Uint8List.fromList(fileBytes));
        if (image == null) {
          return 'Could not decode image';
        }

        return '$extractedText\n\nImage details: ${image.width}x${image.height} pixels, Format: ${image.format}';
      }

      return extractedText;
    } catch (e) {
      return 'Error processing image with OCR: $e';
    }
  }

  /// Disposes the OCR service to free up resources
  void dispose() {
    _ocrService.dispose();
  }
}
