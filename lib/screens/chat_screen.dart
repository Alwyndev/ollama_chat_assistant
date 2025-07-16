import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:ollama_assistant/services/file_service.dart';
// Make sure this import points to the file where FileService is defined.
import 'package:shared_preferences/shared_preferences.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mime/mime.dart';
import '../models/chat_message.dart';
import '../models/server_config.dart';
import '../services/api_service.dart';
import '../widgets/chat_bubble.dart';
import '../widgets/connection_settings.dart';
import '../widgets/model_selector.dart';
import '../widgets/message_input.dart';
import '../widgets/ocr_widget.dart';
import 'dart:io';

// Add connection status enum at the top level
enum ConnectionStatus { notConnected, connecting, connected }

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final List<ChatMessage> _messages = [];
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isLoading = false;
  bool _isTestingConnection = false;
  String _selectedModel = 'phi3:latest';
  bool _showConnectionSettings = false;
  ServerConfig _serverConfig = ServerConfig(ip: 'localhost', port: '11434');
  final ImagePicker _imagePicker = ImagePicker();
  final Map<String, List<ChatMessage>> _modelMemories = {};
  ApiService _apiService = ApiService(
    serverConfig: ServerConfig(ip: 'localhost', port: '11434'),
  );
  final FileService _fileService = FileService();
  // Ensure that FileService class exists in services/file_service.dart

  final Map<String, String> _availableModels = {
    "phi3:latest": "Phi-3 - Lightweight and efficient model",
    "gemma:latest": "Gemma - Google's open model for general tasks",
    "mistral:latest": "Mistral - Strong reasoning capabilities",
    "dolphin-mistral:latest": "Dolphin Mistral - Tuned for conversations",
    "neural-chat:latest": "Neural Chat - Interactive chatbot",
    "deepseek-coder:latest": "DeepSeek Coder - Efficient for programming tasks",
    "starcoder2:latest": "StarCoder 2 - Great for coding + general use",
    "codellama:latest": "CodeLLaMA - For coding tasks",
  };

  // Add connection status enum
  ConnectionStatus _connectionStatus = ConnectionStatus.connected;

  @override
  void initState() {
    super.initState();
    _loadSettings();

    // Initialize memories for all models
    for (var model in _availableModels.keys) {
      _modelMemories[model] = [];
    }
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final savedIp = prefs.getString('server_ip');
    final savedPort = prefs.getString('server_port');

    debugPrint('Loading settings: IP=$savedIp, Port=$savedPort');

    setState(() {
      _serverConfig = ServerConfig(
        ip: savedIp ?? 'localhost',
        port: savedPort ?? '11434',
      );
      _apiService = ApiService(serverConfig: _serverConfig);
    });

    final deviceInfo = DeviceInfoPlugin();
    if (!kIsWeb) {
      final info = await deviceInfo.deviceInfo;
      bool isPhysical = false;
      if (info is AndroidDeviceInfo) {
        isPhysical = info.isPhysicalDevice;
        debugPrint(
          'Android device detected: ${info.model}, Physical: $isPhysical',
        );
      } else if (info is IosDeviceInfo) {
        isPhysical = info.isPhysicalDevice;
        debugPrint('iOS device detected: ${info.model}, Physical: $isPhysical');
      }
      if (isPhysical) {
        setState(() {
          _showConnectionSettings = true;
        });
        debugPrint('Physical device detected - showing connection settings');
      }
    }
  }

  Future<void> _saveSettings(ServerConfig newConfig) async {
    debugPrint('Saving settings: IP=${newConfig.ip}, Port=${newConfig.port}');

    // Always save the settings first, regardless of connection test
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('server_ip', newConfig.ip);
    await prefs.setString('server_port', newConfig.port);

    debugPrint(
      'Settings saved to storage: IP=${newConfig.ip}, Port=${newConfig.port}',
    );

    // Update the UI immediately with the new settings
    setState(() {
      _serverConfig = newConfig;
      _apiService.serverConfig = newConfig;
      _isTestingConnection = true;
    });

    // Now test the connection
    final apiService = ApiService(serverConfig: newConfig);
    final isConnected = await apiService.testConnection();

    setState(() {
      _isTestingConnection = false;
    });

    if (!isConnected) {
      _addErrorMessage("Failed to connect to server at ${newConfig.baseUrl}");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Connection failed to ${newConfig.baseUrl}\nSettings saved but connection failed',
            ),
            backgroundColor: Colors.orange,
            duration: const Duration(seconds: 4),
          ),
        );
      }
      // Don't hide connection settings if connection fails
      return;
    }

    debugPrint('Connection test successful to ${newConfig.baseUrl}');

    setState(() {
      _showConnectionSettings = false;
    });

    _addSystemMessage("Connection settings updated and verified");
  }

  Future<void> _clearSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('server_ip');
    await prefs.remove('server_port');

    debugPrint('Settings cleared from storage');

    setState(() {
      _serverConfig = ServerConfig(ip: 'localhost', port: '11434');
      _apiService.serverConfig = _serverConfig;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Settings reset to default'),
          backgroundColor: Colors.blue,
        ),
      );
    }
  }

  void _addSystemMessage(String text) {
    setState(() {
      _messages.add(ChatMessage(text: text, isUser: false, isSystem: true));
    });
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  Future<void> _sendMessage() async {
    final text = _textController.text.trim();
    if (text.isEmpty || _isLoading) return;

    setState(() {
      _messages.add(ChatMessage(text: text, isUser: true));
      _modelMemories[_selectedModel]?.add(
        ChatMessage(text: text, isUser: true),
      );
      _isLoading = true;
    });
    _scrollToBottom();
    _textController.clear();

    try {
      final assistantReply = await _apiService.sendMessage(
        model: _selectedModel,
        messages: _modelMemories[_selectedModel]!
            .map((m) => ChatMessage(text: m.text, isUser: m.isUser))
            .toList(),
      );

      setState(() {
        _messages.add(
          ChatMessage(
            text: assistantReply,
            isUser: false,
            modelName: _selectedModel,
          ),
        );
        _modelMemories[_selectedModel]?.add(
          ChatMessage(
            text: assistantReply,
            isUser: false,
            modelName: _selectedModel,
          ),
        );
      });
      _scrollToBottom();
    } catch (e) {
      _addErrorMessage('Error: $e\nPlease check server settings');
      setState(() {
        _showConnectionSettings = true;
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _sendFileMessage(
    List<int> fileBytes,
    String fileName,
    String? mimeType,
  ) async {
    if (_isLoading) return;

    // Validate inputs
    if (fileBytes.isEmpty) {
      _addErrorMessage('Error: File is empty or could not be read.');
      return;
    }

    if (fileName.isEmpty) {
      _addErrorMessage('Error: Invalid file name.');
      return;
    }

    setState(() {
      _isLoading = true;
      _messages.add(
        ChatMessage(
          text: "Processing file: $fileName",
          isUser: true,
          isFile: true,
          fileName: fileName,
          fileBytes: fileBytes,
          mimeType: mimeType,
        ),
      );
      _modelMemories[_selectedModel]?.add(
        ChatMessage(
          text: "Processing file: $fileName",
          isUser: true,
          isFile: true,
          fileName: fileName,
          fileBytes: fileBytes,
          mimeType: mimeType,
        ),
      );
    });

    try {
      final extractedText = await _fileService.extractTextFromFile(
        fileBytes,
        fileName,
        mimeType,
      );

      if (extractedText.isEmpty) {
        _addErrorMessage(
          'Error: Could not extract text from file. The file might be binary or unsupported.',
        );
        return;
      }

      setState(() {
        _messages.add(
          ChatMessage(
            text: "Extracted text from $fileName:\n$extractedText",
            isUser: true,
          ),
        );
        _modelMemories[_selectedModel]?.add(
          ChatMessage(
            text: "Extracted text from $fileName:\n$extractedText",
            isUser: true,
          ),
        );
      });

      final assistantReply = await _apiService.sendMessage(
        model: _selectedModel,
        messages: _modelMemories[_selectedModel]!
            .map(
              (m) => ChatMessage(
                text: m.isFile
                    ? "Extracted text from ${m.fileName}:\n${m.text}"
                    : m.text,
                isUser: m.isUser,
              ),
            )
            .toList(),
        timeoutSeconds: 60,
      );

      setState(() {
        _messages.add(
          ChatMessage(
            text: assistantReply,
            isUser: false,
            modelName: _selectedModel,
          ),
        );
        _modelMemories[_selectedModel]?.add(
          ChatMessage(
            text: assistantReply,
            isUser: false,
            modelName: _selectedModel,
          ),
        );
      });
    } catch (e) {
      _addErrorMessage('Error processing file: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _pickFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.any,
        allowMultiple: false,
        withData: false, // Don't load into memory automatically
      );

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        List<int>? fileBytes = file.bytes;
        final fileName = file.name;
        int? fileSize = file.size;

        // If bytes are not loaded (large file), read from path
        if (fileBytes == null && file.path != null) {
          final fileOnDisk = File(file.path!);
          fileSize = await fileOnDisk.length();
          if (fileSize > 512 * 1024 * 1024) {
            // 512 MB
            _addErrorMessage('Error: File is too large (max 512 MB).');
            return;
          }
          fileBytes = await fileOnDisk.readAsBytes();
        } else if (fileBytes != null && fileBytes.length > 512 * 1024 * 1024) {
          _addErrorMessage('Error: File is too large (max 512 MB).');
          return;
        }

        if (fileBytes == null || fileBytes.isEmpty) {
          _addErrorMessage(
            'Error: Could not read file bytes. The file might be too large or inaccessible.',
          );
          return;
        }
        if (fileName.isEmpty) {
          _addErrorMessage('Error: Invalid file name.');
          return;
        }
        final mimeType = lookupMimeType(fileName);
        await _sendFileMessage(fileBytes, fileName, mimeType);
      }
    } catch (e) {
      _addErrorMessage('Error picking file: $e');
    }
  }

  Future<void> _pickImage() async {
    try {
      final pickedFile = await _imagePicker.pickImage(
        source: ImageSource.gallery,
      );
      if (pickedFile != null) {
        final fileBytes = await pickedFile.readAsBytes();
        final fileName = pickedFile.name;

        if (fileBytes.isEmpty) {
          _addErrorMessage(
            'Error: Could not read image file. The file might be corrupted or inaccessible.',
          );
          return;
        }

        if (fileName.isEmpty) {
          _addErrorMessage('Error: Invalid image file name.');
          return;
        }

        final mimeType = lookupMimeType(fileName);
        await _sendFileMessage(fileBytes, fileName, mimeType);
      }
    } catch (e) {
      _addErrorMessage('Error picking image: $e');
    }
  }

  void _addErrorMessage(String text) {
    setState(() {
      _messages.add(ChatMessage(text: text, isUser: false, isError: true));
    });
  }

  void _showOcrDialog() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: OcrWidget(
            onTextExtracted: (String extractedText) {
              Navigator.of(context).pop();
              _textController.text = extractedText;
              // Optionally auto-send the extracted text
              // _sendMessage();
            },
          ),
        ),
      ),
    );
  }

  void _changeModel(String? newValue) {
    if (newValue == null || newValue == _selectedModel) return;

    // Save current model's conversation
    _modelMemories[_selectedModel] = List.from(
      _messages.where((m) => !m.isSystem),
    );

    setState(() {
      _selectedModel = newValue;
      _messages.clear();
      _messages.addAll([
        ChatMessage(
          text: "Switched to model: $newValue\n${_availableModels[newValue]}",
          isUser: false,
          isSystem: true,
        ),
        ...?_modelMemories[newValue],
      ]);
    });
  }

  void _showSettingsModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.settings),
                title: const Text('Connection Settings'),
                onTap: () {
                  Navigator.of(context).pop();
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    builder: (context) => Padding(
                      padding: EdgeInsets.only(
                        bottom: MediaQuery.of(context).viewInsets.bottom,
                      ),
                      child: ConnectionSettings(
                        serverConfig: _serverConfig,
                        onSave: _saveSettings,
                        onCancel: () => Navigator.of(context).pop(),
                        onReset: _clearSettings,
                        onTestConnection: () async {
                          setState(() {
                            _isTestingConnection = true;
                            _connectionStatus = ConnectionStatus.connecting;
                          });
                          final isConnected = await _apiService
                              .testConnection();
                          setState(() {
                            _isTestingConnection = false;
                            _connectionStatus = isConnected
                                ? ConnectionStatus.connected
                                : ConnectionStatus.notConnected;
                          });
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Row(
                                  children: [
                                    Icon(
                                      Icons.circle,
                                      color: isConnected
                                          ? Colors.green
                                          : Colors.red,
                                      size: 12,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      isConnected
                                          ? 'Connection successful!'
                                          : 'Connection failed',
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }
                        },
                        isTestingConnection: _isTestingConnection,
                        selectedModel: _selectedModel,
                        availableModels: _availableModels,
                        onModelChanged: _changeModel,
                      ),
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.model_training),
                title: const Text('Model Selection'),
                onTap: () {
                  Navigator.of(context).pop();
                  showModalBottomSheet(
                    context: context,
                    builder: (context) => Padding(
                      padding: EdgeInsets.only(
                        bottom: MediaQuery.of(context).viewInsets.bottom,
                      ),
                      child: ModelSelector(
                        selectedModel: _selectedModel,
                        availableModels: _availableModels,
                        onChanged: _changeModel,
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: const Text('Ollama Chat Assistant'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.bug_report),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Debug Info'),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Current IP: \\${_serverConfig.ip}'),
                      Text('Current Port: \\${_serverConfig.port}'),
                      Text('Base URL: \\${_serverConfig.baseUrl}'),
                      Text('Show Settings: \\$_showConnectionSettings'),
                      const SizedBox(height: 16),
                      const Text(
                        'To reset settings, use the Reset button in connection settings.',
                      ),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('OK'),
                    ),
                  ],
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: _showSettingsModal,
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              margin: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                color: isDarkMode
                    ? colorScheme.surfaceContainerHighest
                    : colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.circle,
                    size: 12,
                    color: _isTestingConnection
                        ? Colors.orange
                        : _connectionStatus == ConnectionStatus.connected
                        ? Colors.green
                        : Colors.red,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _selectedModel,
                    style: TextStyle(
                      color: isDarkMode
                          ? colorScheme.onSurfaceVariant
                          : colorScheme.onPrimaryContainer,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _availableModels[_selectedModel]!,
                      style: TextStyle(
                        color: isDarkMode
                            ? colorScheme.onSurfaceVariant
                            : colorScheme.onPrimaryContainer,
                        fontStyle: FontStyle.italic,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                reverse: false,
                padding: const EdgeInsets.all(8),
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final message = _messages[index];
                  return ChatBubble(
                    message: message,
                    colorScheme: colorScheme,
                    isDarkMode: isDarkMode,
                  );
                },
              ),
            ),
            MessageInput(
              textController: _textController,
              isLoading: _isLoading,
              onSend: _sendMessage,
              onPickFile: _pickFile,
              onPickImage: _pickImage,
              onOcr: _showOcrDialog,
            ),
          ],
        ),
      ),
    );
  }
}
