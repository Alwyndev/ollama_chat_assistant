import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import '../services/ocr_service.dart';

class OcrWidget extends StatefulWidget {
  final Function(String) onTextExtracted;

  const OcrWidget({super.key, required this.onTextExtracted});

  @override
  State<OcrWidget> createState() => _OcrWidgetState();
}

class _OcrWidgetState extends State<OcrWidget> {
  final OcrService _ocrService = OcrService();
  final ImagePicker _imagePicker = ImagePicker();
  bool _isProcessing = false;

  @override
  void dispose() {
    _ocrService.dispose();
    super.dispose();
  }

  Future<void> _pickImageFromCamera() async {
    try {
      setState(() {
        _isProcessing = true;
      });

      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image != null) {
        final bytes = await image.readAsBytes();
        await _processImage(bytes);
      }
    } catch (e) {
      _showError('Error capturing image: $e');
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  Future<void> _pickImageFromGallery() async {
    try {
      setState(() {
        _isProcessing = true;
      });

      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image != null) {
        final bytes = await image.readAsBytes();
        await _processImage(bytes);
      }
    } catch (e) {
      _showError('Error picking image: $e');
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  Future<void> _pickImageFromFile() async {
    try {
      setState(() {
        _isProcessing = true;
      });

      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
      );

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        if (file.bytes != null) {
          await _processImage(file.bytes!);
        } else {
          _showError('Could not read image file');
        }
      }
    } catch (e) {
      _showError('Error picking file: $e');
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  Future<void> _processImage(Uint8List imageBytes) async {
    try {
      final extractedText = await _ocrService.extractTextFromImage(imageBytes);

      if (extractedText.startsWith('Error:') ||
          extractedText.startsWith('No text found')) {
        _showError(extractedText);
      } else {
        widget.onTextExtracted(extractedText);
        _showSuccess('Text extracted successfully!');
      }
    } catch (e) {
      _showError('Error processing image: $e');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text(
          'Extract Text from Image',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        if (_isProcessing)
          const Column(
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 8),
              Text('Processing image...'),
            ],
          )
        else
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildActionButton(
                icon: Icons.camera_alt,
                label: 'Camera',
                onPressed: _pickImageFromCamera,
              ),
              _buildActionButton(
                icon: Icons.photo_library,
                label: 'Gallery',
                onPressed: _pickImageFromGallery,
              ),
              _buildActionButton(
                icon: Icons.folder_open,
                label: 'File',
                onPressed: _pickImageFromFile,
              ),
            ],
          ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            shape: const CircleBorder(),
            padding: const EdgeInsets.all(16),
          ),
          child: Icon(icon, size: 24),
        ),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}
