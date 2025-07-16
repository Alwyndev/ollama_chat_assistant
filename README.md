# Ollama Chat Assistant

A Flutter-based mobile and desktop application that provides a user-friendly interface for interacting with Ollama AI models. The app supports file uploads, image processing, and multiple AI models with a clean, modern UI.

## 🚀 Features

- **Multi-Platform Support**: Android APK and Windows executable
- **File Processing**: Upload and process any file type (up to 512MB)
- **Image Analysis**: Extract text from images using OCR
- **Code Formatting**: Automatic syntax highlighting for code files
- **Model Switching**: Choose from 8 different AI models
- **Separate Conversations**: Independent chat history for each model
- **Connection Management**: Easy server configuration for mobile devices
- **Markdown Support**: Rich text formatting with code block copying

## 📱 Supported Platforms

- **Android**: APK installation with full feature support
- **Windows**: Native executable with all features
- **iOS**: Ready for App Store deployment (requires Apple Developer account)
- **macOS**: Ready for Mac App Store deployment
- **Linux**: Ready for distribution
- **Web**: Ready for browser deployment

## 🛠️ Prerequisites

### For Development:
- Flutter SDK (latest stable version)
- Dart SDK
- Android Studio / VS Code
- Git

### For Users:
- Ollama installed and running on their computer
- Ollama configured to accept external connections:
  ```bash
  OLLAMA_HOST=0.0.0.0:11434 ollama serve
  ```
- Firewall configured to allow port 11434

## 🚀 Quick Start

### Development Setup:
```bash
# Clone the repository
git clone <your-repo-url>
cd ollama_assistant

# Install dependencies
flutter pub get

# Run on connected device
flutter run

# Build for distribution
flutter build apk --release
flutter build windows --release
```

### User Installation:

**Android:**
1. Enable "Install from unknown sources" in Settings → Security
2. Install the APK file
3. Configure connection settings in the app

**Windows:**
1. Extract the distribution ZIP file
2. Run `ollama_assistant.exe`
3. Configure connection settings in the app

## 📋 Supported AI Models

- **phi3:latest** - Lightweight and efficient model
- **gemma:latest** - Google's open model for general tasks
- **mistral:latest** - Strong reasoning capabilities
- **dolphin-mistral:latest** - Tuned for conversations
- **neural-chat:latest** - Interactive chatbot
- **deepseek-coder:latest** - Efficient for programming tasks
- **starcoder2:latest** - Great for coding + general use
- **codellama:latest** - For coding tasks

## 🔧 Configuration

### Connection Settings:
- **Server IP**: Your computer's local IP address (e.g., 192.168.1.8)
- **Port**: 11434 (default Ollama port)
- **Network**: Both devices must be on the same WiFi network

### File Support:
- **Text Files**: .txt, .md, .json, .xml, .csv, etc.
- **Code Files**: .py, .js, .java, .cpp, .html, .css, etc.
- **Documents**: .pdf (text extraction)
- **Images**: .jpg, .png, .gif (OCR text extraction)
- **Large Files**: Up to 512MB supported

## 🏗️ Project Structure

```
lib/
├── main.dart                 # App entry point
├── models/
│   ├── chat_message.dart     # Message data model
│   └── server_config.dart    # Server configuration model
├── screens/
│   └── chat_screen.dart      # Main chat interface
├── services/
│   ├── api_service.dart      # Ollama API communication
│   └── file_service.dart     # File processing utilities
└── widgets/
    ├── chat_bubble.dart      # Message display widget
    ├── connection_settings.dart # Server configuration UI
    ├── model_selector.dart   # AI model selection
    └── message_input.dart    # Input interface
```

## 🔌 Dependencies

### Core Dependencies:
- `flutter`: UI framework
- `shared_preferences`: Settings persistence
- `device_info_plus`: Device detection
- `file_picker`: File selection
- `image_picker`: Image selection
- `mime`: File type detection
- `image`: Image processing
- `pdf_text`: PDF text extraction
- `flutter_markdown`: Markdown rendering

### Development Dependencies:
- `flutter_test`: Testing framework
- `flutter_lints`: Code quality

## 🧪 Testing

```bash
# Run unit tests
flutter test

# Run widget tests
flutter test test/widget_test.dart

# Run integration tests
flutter drive --target=test_driver/app.dart
```

## 📦 Distribution

### Building for Distribution:
```bash
# Android APK
flutter build apk --release

# Windows Executable
flutter build windows --release

# iOS (requires Mac)
flutter build ios --release

# macOS (requires Mac)
flutter build macos --release

# Linux
flutter build linux --release

# Web
flutter build web --release
```

### Distribution Files:
- **Android**: `build/app/outputs/flutter-apk/app-release.apk`
- **Windows**: `build/windows/x64/runner/Release/` folder
- **Distribution Guide**: See `DISTRIBUTION_GUIDE.md`

## 🐛 Troubleshooting

### Common Issues:

1. **Connection Failed**
   - Verify Ollama is running with external access
   - Check IP address is correct
   - Ensure firewall allows port 11434

2. **App Won't Install (Android)**
   - Enable "Install from unknown sources"
   - Check APK file integrity

3. **App Won't Start (Windows)**
   - Ensure all DLL files are present
   - Check Windows Defender settings
   - Run as administrator if needed

### Debug Tools:
- Use the debug button (🐛) in the app to view current settings
- Check connection guide for detailed setup instructions
- Review logs in the app for error details

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- [Ollama](https://ollama.ai/) for the AI model server
- [Flutter](https://flutter.dev/) for the cross-platform framework
- [pub.dev](https://pub.dev/) for the excellent packages

## 📞 Support

- **Documentation**: Check the `CONNECTION_GUIDE.md` for setup instructions
- **Issues**: Report bugs and feature requests via GitHub Issues
- **Discussions**: Use GitHub Discussions for questions and help

---

**Note**: This app requires Ollama to be running on the user's computer. The app itself doesn't require internet access and all data stays local.

## OCR Feature

The app now includes OCR (Optical Character Recognition) functionality that allows you to:

- **Extract text from images** using your device's camera
- **Process images from gallery** or file picker
- **Automatically detect and recognize text** in various languages
- **Send extracted text directly to the chat** for AI processing

### How to use OCR:

1. Tap the **document scanner icon** (📄) in the message input area
2. Choose from three options:
   - **Camera**: Take a photo of text to extract
   - **Gallery**: Select an image from your device
   - **File**: Pick an image file from storage
3. The app will process the image and extract any readable text
4. The extracted text will be automatically inserted into the message input
5. You can then send it to the AI model for further processing

### OCR Requirements:

- **Android**: Requires Android 4.4 (API level 19) or higher
- **iOS**: Requires iOS 12.0 or higher
- **Internet connection**: Required for initial ML Kit model download (one-time)
