import 'package:flutter/material.dart';

class PreferencesScreen extends StatefulWidget {
  final Function(List<String>) onSubmit;
  final VoidCallback onBack;

  const PreferencesScreen({
    required this.onSubmit,
    required this.onBack,
    Key? key,
  }) : super(key: key);

  @override
  State<PreferencesScreen> createState() => _PreferencesScreenState();
}

class _PreferencesScreenState extends State<PreferencesScreen> {
  final Color primaryColor = const Color(0xFF1B4242);
  final List<String> _selectedPreferences = [];

  final Map<String, List<String>> _preferenceOptions = {
    'Chattiness': [
      "I love to chat",
      "I'm chatty when I feel comfortable",
      "I'm the quiet type",
    ],
    'Smoking': [
      "I'm fine with smoking",
      "Cigarette breaks outside the car are ok",
      "No smoking, please",
    ],
    'Music': [
      "It's all about the playlist!",
      "I'll jam depending on the mood",
      "Silence is golden",
    ],
  };

  void _togglePreference(String preference) {
    setState(() {
      if (_selectedPreferences.contains(preference)) {
        _selectedPreferences.remove(preference);
      } else {
        _selectedPreferences.add(preference);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Travel Preferences"),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: widget.onBack,
        ),
      ),
      body: SafeArea(
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                const Text(
                  'Plan Your Dream Trip',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 24),
                Expanded(
                  child: ListView(
                    children: _preferenceOptions.entries.map((entry) {
                      return _buildPreferenceGroup(
                        icon: _getPreferenceIcon(entry.key),
                        title: entry.key,
                        options: entry.value,
                        selectedOptions: _selectedPreferences,
                        onToggle: _togglePreference,
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    if (_selectedPreferences.isNotEmpty) {
                      widget.onSubmit(_selectedPreferences);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Please select at least one preference')),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                    backgroundColor: primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    "Save",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  IconData _getPreferenceIcon(String preferenceType) {
    switch (preferenceType) {
      case 'Chattiness':
        return Icons.chat_bubble_outline;
      case 'Smoking':
        return Icons.smoking_rooms_outlined;
      case 'Music':
        return Icons.music_note_outlined;
      default:
        return Icons.check_box_outline_blank;
    }
  }

  Widget _buildPreferenceGroup({
    required IconData icon,
    required String title,
    required List<String> options,
    required List<String> selectedOptions,
    required ValueChanged<String> onToggle,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          children: [
            ListTile(
              leading: Icon(icon, color: primaryColor),
              title: Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
            ...options.map((option) {
              return CheckboxListTile(
                value: selectedOptions.contains(option),
                onChanged: (_) => onToggle(option),
                title: Text(option),
                controlAffinity: ListTileControlAffinity.trailing,
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
}