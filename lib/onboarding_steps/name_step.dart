import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:innerfive/models/user_data.dart';
import 'package:innerfive/widgets/animation_extensions.dart';
import 'package:innerfive/widgets/custom_button.dart';

class NameStep extends StatefulWidget {
  final UserData userData;
  final VoidCallback onContinue;

  const NameStep({super.key, required this.userData, required this.onContinue});

  @override
  State<NameStep> createState() => _NameStepState();
}

class _NameStepState extends State<NameStep> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _firstNameController;
  late final TextEditingController _middleNameController;
  late final TextEditingController _lastNameController;

  @override
  void initState() {
    super.initState();
    _firstNameController = TextEditingController(
      text: widget.userData.firstName,
    );
    _middleNameController = TextEditingController(
      text: widget.userData.middleName,
    );
    _lastNameController = TextEditingController(text: widget.userData.lastName);
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _middleNameController.dispose();
    _lastNameController.dispose();
    super.dispose();
  }

  void _handleContinue() {
    if (_formKey.currentState!.validate()) {
      widget.userData.firstName = _firstNameController.text.trim();
      widget.userData.middleName = _middleNameController.text.trim().isNotEmpty
          ? _middleNameController.text.trim()
          : null;
      widget.userData.lastName = _lastNameController.text.trim();
      widget.onContinue();
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
                  RichText(
                    text: const TextSpan(
                      style: TextStyle(
                        fontSize: 24,
                        color: Colors.white,
                        height: 1.4,
                      ),
                      children: [
                        TextSpan(
                          text: 'To begin your journey,\nplease tell us ',
                        ),
                        TextSpan(
                          text: 'your name',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        TextSpan(text: ' first.'),
                      ],
                    ),
                  ).animateOnPageLoad(delay: 400.ms),
                  const SizedBox(height: 30),
                  TextFormField(
                    controller: _firstNameController,
                    style: const TextStyle(color: Colors.white),
                    decoration: _inputDecoration('First Name'),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter your first name.';
                      }
                      return null;
                    },
                  ).animateOnPageLoad(delay: 600.ms),
                  const SizedBox(height: 15),
                  TextFormField(
                    controller: _middleNameController,
                    style: const TextStyle(color: Colors.white),
                    decoration: _inputDecoration('Middle Name (Optional)'),
                  ).animateOnPageLoad(delay: 700.ms),
                  const SizedBox(height: 15),
                  TextFormField(
                    controller: _lastNameController,
                    style: const TextStyle(color: Colors.white),
                    decoration: _inputDecoration('Last Name'),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter your last name.';
                      }
                      return null;
                    },
                  ).animateOnPageLoad(delay: 800.ms),
                ],
              ),
            ),
          ),
          const SizedBox(height: 30),
          CustomButton(
            text: 'Continue',
            onPressed: _handleContinue,
            isOutlined: true,
            textColor: Colors.white,
            borderColor: Colors.white,
          ).animateOnPageLoad(delay: 1000.ms),
          const SizedBox(height: 20),
        ],
      ),
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
