import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:innerfive/models/user_data.dart';
import 'package:innerfive/widgets/animation_extensions.dart';
import 'package:innerfive/widgets/custom_button.dart';

class BirthDateStep extends StatefulWidget {
  final UserData userData;
  final VoidCallback onNextStep;

  const BirthDateStep({
    super.key,
    required this.userData,
    required this.onNextStep,
  });

  @override
  State<BirthDateStep> createState() => _BirthDateStepState();
}

class _BirthDateStepState extends State<BirthDateStep> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _yearController;
  late final TextEditingController _monthController;
  late final TextEditingController _dayController;

  @override
  void initState() {
    super.initState();
    _yearController = TextEditingController(text: widget.userData.year);
    _monthController = TextEditingController(text: widget.userData.month);
    _dayController = TextEditingController(text: widget.userData.day);
  }

  @override
  void dispose() {
    _yearController.dispose();
    _monthController.dispose();
    _dayController.dispose();
    super.dispose();
  }

  void _handleNextStep() {
    if (_formKey.currentState!.validate()) {
      widget.userData.year = _yearController.text.trim();
      widget.userData.month = _monthController.text.trim();
      widget.userData.day = _dayController.text.trim();
      widget.onNextStep();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Now, please enter your exact date of birth for your Eidos Fati analysis. This is crucial information for revealing your innate potential and the flow of your destiny.',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                      height: 1.5,
                    ),
                  ).animateOnPageLoad(delay: 400.ms),
                  const SizedBox(height: 30),
                  _buildDateInputRow().animateOnPageLoad(delay: 600.ms),
                ],
              ),
            ),
          ),
          const SizedBox(height: 30),
          CustomButton(
            text: 'Next Step',
            onPressed: _handleNextStep,
            isOutlined: true,
            textColor: Colors.white,
            borderColor: Colors.white,
          ).animateOnPageLoad(delay: 800.ms),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildDateInputRow() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: TextFormField(
            controller: _yearController,
            style: const TextStyle(color: Colors.white),
            decoration: _inputDecoration('e.g., 1986'),
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            maxLength: 4,
            validator: (value) {
              if (value == null || value.length != 4) {
                return '4 digits';
              }
              return null;
            },
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: TextFormField(
            controller: _monthController,
            style: const TextStyle(color: Colors.white),
            decoration: _inputDecoration('e.g., 08'),
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            maxLength: 2,
            validator: (value) {
              if (value == null || value.isEmpty) return 'Required';
              final month = int.tryParse(value);
              if (month == null || month < 1 || month > 12) return '1-12';
              return null;
            },
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: TextFormField(
            controller: _dayController,
            style: const TextStyle(color: Colors.white),
            decoration: _inputDecoration('e.g., 25'),
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            maxLength: 2,
            validator: (value) {
              if (value == null || value.isEmpty) return 'Required';
              final day = int.tryParse(value);
              if (day == null || day < 1 || day > 31) return '1-31';
              return null;
            },
          ),
        ),
      ],
    );
  }

  InputDecoration _inputDecoration(String hintText) {
    return InputDecoration(
      filled: true,
      fillColor: Colors.black.withAlpha(128),
      hintText: hintText,
      hintStyle: TextStyle(color: Colors.white.withAlpha(128)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.white.withAlpha(64)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.white),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.redAccent),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.redAccent, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
    );
  }
}
