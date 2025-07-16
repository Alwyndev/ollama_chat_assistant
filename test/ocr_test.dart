import 'package:flutter_test/flutter_test.dart';
import 'package:ollama_assistant/services/ocr_service.dart';

void main() {
  group('OCR Service Tests', () {
    test('OCR Service can be instantiated', () {
      final ocrService = OcrService();
      expect(ocrService, isNotNull);
      ocrService.dispose();
    });

    test('OCR Service can check availability', () async {
      final ocrService = OcrService();
      final isAvailable = await ocrService.isAvailable();
      expect(isAvailable, isA<bool>());
      ocrService.dispose();
    });
  });
}
