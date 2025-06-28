import 'package:flutter/material.dart';

class ModelSelector extends StatelessWidget {
  final String selectedModel;
  final Map<String, String> availableModels;
  final Function(String?) onChanged;

  const ModelSelector({
    super.key,
    required this.selectedModel,
    required this.availableModels,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isDarkMode
            ? Theme.of(context).colorScheme.surfaceContainerHighest
            : Theme.of(context).colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      margin: const EdgeInsets.all(8),
      child: Row(
        children: [
          const Icon(Icons.model_training, size: 20),
          const SizedBox(width: 8),
          const Text('Model:'),
          const SizedBox(width: 8),
          Expanded(
            child: DropdownButton<String>(
              value: selectedModel,
              isExpanded: true,
              underline: const SizedBox(),
              items: availableModels.keys.map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }
}
