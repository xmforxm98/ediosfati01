import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:innerfive/models/user_data.dart';
import 'package:innerfive/widgets/animation_extensions.dart';
import 'package:innerfive/widgets/custom_button.dart';
import 'dart:math';

class NicknameStep extends StatefulWidget {
  final UserData userData;
  final VoidCallback onContinue;

  const NicknameStep({
    super.key,
    required this.userData,
    required this.onContinue,
  });

  @override
  State<NicknameStep> createState() => _NicknameStepState();
}

class _NicknameStepState extends State<NicknameStep> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nicknameController;
  final Random _random = Random();

  final List<String> _coolNicknames = [
    'Seeker',
    'Dreamer',
    'Explorer',
    'Wanderer',
    'Mystic',
    'Phoenix',
    'Oracle',
    'Sage',
    'Voyager',
    'Cosmos',
    'Zenith',
    'Aurora',
    'Nova',
    'Stellar',
    'Echo',
    'Mirage',
    'Cipher',
    'Prism',
    'Quasar',
    'Solaris',
    'Nebula',
    'Aether',
    'Vertex',
    'Lumina',
    'Infinity',
    'Karma',
    'Spirit',
    'Vision',
    'Journey',
    'Destiny',
  ];

  @override
  void initState() {
    super.initState();
    _nicknameController = TextEditingController(text: widget.userData.nickname);
  }

  @override
  void dispose() {
    _nicknameController.dispose();
    super.dispose();
  }

  void _generateRandomNickname() {
    final randomNickname =
        _coolNicknames[_random.nextInt(_coolNicknames.length)];
    setState(() {
      _nicknameController.text = randomNickname;
    });
  }

  void _handleContinue() {
    if (_formKey.currentState!.validate()) {
      widget.userData.nickname = _nicknameController.text.trim();
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
                        TextSpan(text: 'Before we start,\n'),
                        TextSpan(
                          text: 'what would you like us to call you?',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ).animateOnPageLoad(delay: 400.ms),
                  const SizedBox(height: 30),
                  TextFormField(
                    controller: _nicknameController,
                    style: const TextStyle(color: Colors.white),
                    decoration: _inputDecoration('Your preferred name'),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter how you\'d like to be called.';
                      }
                      return null;
                    },
                  ).animateOnPageLoad(delay: 600.ms),
                  const SizedBox(height: 20),
                  Center(
                    child: TextButton.icon(
                      onPressed: _generateRandomNickname,
                      icon: const Icon(Icons.shuffle, color: Colors.white70),
                      label: const Text(
                        'Generate Random Name',
                        style: TextStyle(color: Colors.white70),
                      ),
                      style: TextButton.styleFrom(
                        backgroundColor: Colors.white.withAlpha(128),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                          side: BorderSide(
                            color: Colors.white.withAlpha(192),
                          ),
                        ),
                      ),
                    ),
                  ).animateOnPageLoad(delay: 700.ms),
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
          ).animateOnPageLoad(delay: 800.ms),
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
        borderSide: BorderSide(color: Colors.white.withAlpha(192)),
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
