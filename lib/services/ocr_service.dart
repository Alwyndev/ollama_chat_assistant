import 'dart:typed_data';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image/image.dart' as img;

class OcrService {
  final TextRecognizer _textRecognizer = TextRecognizer();

  /// Extracts text from an image using OCR
  /// Returns the recognized text or an error message
  Future<String> extractTextFromImage(List<int> imageBytes) async {
    try {
      // Decode the image to get format information
      final image = img.decodeImage(Uint8List.fromList(imageBytes));
      if (image == null) {
        return 'Error: Could not decode image. Please ensure the image format is supported (JPEG, PNG, BMP, etc.).';
      }

      // Convert image to PNG format for ML Kit
      final pngBytes = img.encodePng(image);

      // Convert image to InputImage format for ML Kit
      final inputImage = InputImage.fromBytes(
        bytes: pngBytes,
        metadata: InputImageMetadata(
          size: Size(image.width.toDouble(), image.height.toDouble()),
          rotation: InputImageRotation.rotation0deg,
          format: InputImageFormat.bgra8888,
          bytesPerRow: image.width * 4,
        ),
      );

      // Perform text recognition
      final RecognizedText recognizedText = await _textRecognizer.processImage(
        inputImage,
      );

      if (recognizedText.text.isEmpty) {
        return 'No text found in the image. Please ensure the image contains clear, readable text with good contrast.';
      }

      // Format the recognized text
      String extractedText = '';
      for (TextBlock block in recognizedText.blocks) {
        for (TextLine line in block.lines) {
          extractedText += '${line.text}\n';
        }
        extractedText += '\n'; // Add extra line break between blocks
      }

      return extractedText.trim();
    } catch (e) {
      if (e.toString().contains('permission')) {
        return 'Error: Camera or storage permission denied. Please grant the necessary permissions.';
      } else if (e.toString().contains('network')) {
        return 'Error: Network connection required for OCR. Please check your internet connection.';
      } else {
        return 'Error performing OCR: $e';
      }
    }
  }

  /// Extracts text from an image file
  Future<String> extractTextFromImageFile(File imageFile) async {
    try {
      final bytes = await imageFile.readAsBytes();
      return await extractTextFromImage(bytes);
    } catch (e) {
      return 'Error reading image file: $e';
    }
  }

  /// Extracts text from multiple images
  Future<List<String>> extractTextFromMultipleImages(
    List<List<int>> imageBytesList,
  ) async {
    List<String> results = [];

    for (int i = 0; i < imageBytesList.length; i++) {
      try {
        final result = await extractTextFromImage(imageBytesList[i]);
        results.add('Image ${i + 1}:\n$result\n');
      } catch (e) {
        results.add('Image ${i + 1}: Error - $e\n');
      }
    }

    return results;
  }

  /// Checks if the OCR service is available
  Future<bool> isAvailable() async {
    try {
      // Try to create a simple test image and process it
      final testImage = img.Image(width: 100, height: 100);
      final testBytes = img.encodePng(testImage);

      final inputImage = InputImage.fromBytes(
        bytes: testBytes,
        metadata: InputImageMetadata(
          size: const Size(100, 100),
          rotation: InputImageRotation.rotation0deg,
          format: InputImageFormat.bgra8888,
          bytesPerRow: 400,
        ),
      );

      await _textRecognizer.processImage(inputImage);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Disposes the text recognizer to free up resources
  void dispose() {
    _textRecognizer.close();
  }
}
