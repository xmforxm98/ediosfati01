import 'package:flutter/material.dart';
import 'package:csc_picker_plus/csc_picker_plus.dart';
import 'package:flutter_animate/flutter_animate.dart';

import 'package:innerfive/models/user_data.dart';
import 'package:innerfive/widgets/custom_button.dart';
import 'package:innerfive/widgets/custom_error_message.dart';

class CityStep extends StatefulWidget {
  final UserData userData;
  final VoidCallback onContinue;

  const CityStep({super.key, required this.userData, required this.onContinue});

  @override
  State<CityStep> createState() => _CityStepState();
}

class _CityStepState extends State<CityStep> {
  String? _country;
  String? _state;
  String? _city;

  @override
  void initState() {
    super.initState();
    // Initialize with existing data if available
    _country = widget.userData.country;
    _state = widget.userData.state;
    _city = widget.userData.city;
  }

  void _handleContinue() {
    if (_country == null || _city == null) {
      _showError('Please select your country and city of birth.');
      return;
    }

    // Save data to the model
    widget.userData.country = _country;
    widget.userData.state = _state;
    widget.userData.city = _city;

    // Trigger the callback to move to the next page (loading screen)
    widget.onContinue();
  }

  void _showError(String message) {
    if (!mounted) return;
    CustomErrorMessage.show(context, message);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Now, for a more accurate analysis of your destiny, please provide your country and city of birth. This place is crucial for the analysis.',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                    height: 1.5,
                  ),
                ).animate().fadeIn(delay: 400.ms),
                const SizedBox(height: 30),
                _buildCscPicker().animate().fadeIn(delay: 600.ms),
                const SizedBox(height: 10),
              ],
            ),
          ),
          const SizedBox(height: 30),
          CustomButton(
            text: 'Start Analysis',
            onPressed: _handleContinue,
            isOutlined: true,
            textColor: Colors.white,
            borderColor: Colors.white,
          ).animate().fadeIn(delay: 800.ms),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildCscPicker() {
    return Theme(
      data: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF202020),
        dialogTheme: DialogTheme(
          backgroundColor: const Color(0xFF2c2c2c),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.black.withAlpha(128),
          hintStyle: TextStyle(color: Colors.white.withAlpha(128)),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          prefixIconColor: Colors.white.withAlpha(128),
        ),
      ),
      child: CSCPickerPlus(
        onCountryChanged: (value) => setState(() => _country = value),
        onStateChanged: (value) => setState(() => _state = value),
        onCityChanged: (value) => setState(() => _city = value),
        countryDropdownLabel: _country ?? "Country / Region",
        stateDropdownLabel: _state ?? "State / Province",
        cityDropdownLabel: _city ?? "City",
        dropdownDecoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Colors.black.withAlpha(128),
          border: Border.all(color: Colors.white.withAlpha(128)),
        ),
        disabledDropdownDecoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Colors.black.withAlpha(64),
          border: Border.all(color: Colors.white.withAlpha(64)),
        ),
        selectedItemStyle: const TextStyle(color: Colors.white, fontSize: 16),
        dropdownItemStyle: const TextStyle(color: Colors.white, fontSize: 16),
        dropdownHeadingStyle: const TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
        searchBarRadius: 12.0,
        dropdownDialogRadius: 12.0,
      ),
    );
  }
}
