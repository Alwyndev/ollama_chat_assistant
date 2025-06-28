import 'package:flutter/material.dart';
import '../models/server_config.dart';

class ConnectionSettings extends StatefulWidget {
  final ServerConfig serverConfig;
  final Function(ServerConfig) onSave;
  final Function() onCancel;
  final Function() onTestConnection;
  final Function() onReset;
  final bool isTestingConnection;

  const ConnectionSettings({
    super.key,
    required this.serverConfig,
    required this.onSave,
    required this.onCancel,
    required this.onTestConnection,
    required this.onReset,
    required this.isTestingConnection,
  });

  @override
  State<ConnectionSettings> createState() => _ConnectionSettingsState();
}

class _ConnectionSettingsState extends State<ConnectionSettings> {
  late TextEditingController ipController;
  late TextEditingController portController;

  @override
  void initState() {
    super.initState();
    ipController = TextEditingController(text: widget.serverConfig.ip);
    portController = TextEditingController(text: widget.serverConfig.port);
  }

  @override
  void dispose() {
    ipController.dispose();
    portController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.1),
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(
                Icons.settings,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 8),
              const Text(
                'Server Connection Settings',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextField(
            controller: ipController,
            decoration: const InputDecoration(
              labelText: 'Server IP Address',
              hintText: '192.168.1.8 or localhost',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.computer),
            ),
            keyboardType: TextInputType.text,
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: 12),
          TextField(
            controller: portController,
            decoration: const InputDecoration(
              labelText: 'Port',
              hintText: '11434',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.router),
            ),
            keyboardType: TextInputType.number,
            textInputAction: TextInputAction.done,
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(
                context,
              ).colorScheme.primaryContainer.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: Theme.of(
                  context,
                ).colorScheme.primary.withValues(alpha: 0.2),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: 16,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Mobile Connection Guide:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  '1. Use your computer\'s LAN IP (e.g., 192.168.1.8)\n'
                  '2. Ensure both devices are on the same WiFi network\n'
                  '3. Start Ollama with: OLLAMA_HOST=0.0.0.0:11434 ollama serve\n'
                  '4. Allow firewall access for port 11434',
                  style: TextStyle(fontSize: 12),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton.icon(
                onPressed: widget.onReset,
                icon: const Icon(Icons.refresh, size: 16),
                label: const Text('Reset'),
              ),
              Row(
                children: [
                  TextButton(
                    onPressed: widget.onCancel,
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed: widget.isTestingConnection
                        ? null
                        : () async {
                            final newConfig = ServerConfig(
                              ip: ipController.text.trim(),
                              port: portController.text.trim(),
                            );
                            widget.onSave(newConfig);
                          },
                    icon: widget.isTestingConnection
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.save),
                    label: Text(
                      widget.isTestingConnection ? 'Testing...' : 'Save & Test',
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
