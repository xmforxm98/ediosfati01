import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:innerfive/models/user_data.dart';
import 'package:innerfive/widgets/animation_extensions.dart';
import 'package:innerfive/widgets/custom_button.dart';

class BirthTimeStep extends StatefulWidget {
  final UserData userData;
  final VoidCallback onComplete;

  const BirthTimeStep({
    super.key,
    required this.userData,
    required this.onComplete,
  });

  @override
  State<BirthTimeStep> createState() => _BirthTimeStepState();
}

class _BirthTimeStepState extends State<BirthTimeStep> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _hourController;
  late final TextEditingController _minuteController;
  bool _hasRequiredTime = false;

  @override
  void initState() {
    super.initState();
    _hourController = TextEditingController(text: widget.userData.hour);
    _minuteController = TextEditingController(text: widget.userData.minute);

    _checkRequiredTime();
  }

  @override
  void dispose() {
    _hourController.dispose();
    _minuteController.dispose();
    super.dispose();
  }

  void _checkRequiredTime() {
    setState(() {
      _hasRequiredTime = _hourController.text.trim().isNotEmpty &&
          _minuteController.text.trim().isNotEmpty;
    });
  }

  void _handleComplete() {
    if (!_hasRequiredTime) return;

    if (_formKey.currentState!.validate()) {
      widget.userData.hour = _hourController.text.trim();
      widget.userData.minute = _minuteController.text.trim();
      widget.onComplete();
    }
  }

  void _handleSkip() {
    widget.userData.hour = null;
    widget.userData.minute = null;
    widget.onComplete();
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
                    'For a more precise analysis of your destiny, please provide your time of birth. This information is vital for revealing your innate energy and potential.',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                      height: 1.5,
                    ),
                  ).animateOnPageLoad(delay: 400.ms),
                  const SizedBox(height: 30),
                  _buildTimeInputRow().animateOnPageLoad(delay: 600.ms),
                  const SizedBox(height: 20),
                  _buildSkipSection().animateOnPageLoad(delay: 800.ms),
                ],
              ),
            ),
          ),
          const SizedBox(height: 30),
          CustomButton(
            text: 'Next',
            onPressed: _hasRequiredTime ? _handleComplete : null,
            isOutlined: true,
            textColor:
                _hasRequiredTime ? Colors.white : Colors.white.withAlpha(128),
            borderColor:
                _hasRequiredTime ? Colors.white : Colors.white.withAlpha(128),
          ).animateOnPageLoad(delay: 1000.ms),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildTimeInputRow() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: TextFormField(
            controller: _hourController,
            style: const TextStyle(color: Colors.white),
            decoration: _inputDecoration('e.g., 14', label: 'Hour'),
            textAlign: TextAlign.center,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            maxLength: 2,
            onChanged: (_) => _checkRequiredTime(),
            validator: (value) {
              if (value == null || value.isEmpty) return 'Required';
              final hour = int.tryParse(value);
              if (hour == null || hour < 0 || hour > 23) return '0-23';
              return null;
            },
          ),
        ),
        const Padding(
          padding: EdgeInsets.only(top: 18.0),
          child: Text(':', style: TextStyle(color: Colors.white, fontSize: 24)),
        ),
        Expanded(
          child: TextFormField(
            controller: _minuteController,
            style: const TextStyle(color: Colors.white),
            decoration: _inputDecoration('e.g., 30', label: 'Minute'),
            textAlign: TextAlign.center,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            maxLength: 2,
            onChanged: (_) => _checkRequiredTime(),
            validator: (value) {
              if (value == null || value.isEmpty) return 'Required';
              final minute = int.tryParse(value);
              if (minute == null || minute < 0 || minute > 59) return '0-59';
              return null;
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSkipSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Don't know the exact time of your birth? Don't worry. A basic analysis is possible with just your birth date. However, please note that the time of birth is important for a deeper and more precise insight.",
          style: TextStyle(color: Colors.white70, fontSize: 13, height: 1.4),
        ),
        const SizedBox(height: 15),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: _handleSkip,
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.white60,
              side: BorderSide(color: Colors.white.withAlpha(128)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text("I don't know the time"),
          ),
        ),
      ],
    );
  }

  InputDecoration _inputDecoration(String hintText, {String? label}) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.white70),
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
      counterText: "",
    );
  }
}
