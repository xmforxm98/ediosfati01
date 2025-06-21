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
  final FocusNode _focusNode = FocusNode();
  final Random _random = Random();
  bool _hasText = false; // 텍스트 입력 상태 추적

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

    // 초기 텍스트 상태 확인
    _hasText = _nicknameController.text.trim().isNotEmpty;

    // 화면 로드 시 텍스트 필드에 자동 포커스하여 키보드 활성화
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) {
            _focusNode.requestFocus();
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _nicknameController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onTextChanged(String text) {
    setState(() {
      _hasText = text.trim().isNotEmpty;
    });
  }

  void _generateRandomNickname() {
    final randomNickname =
        _coolNicknames[_random.nextInt(_coolNicknames.length)];
    setState(() {
      _nicknameController.text = randomNickname;
      _hasText = true; // 랜덤 이름 생성 시에도 버튼 활성화
    });
  }

  void _handleContinue() {
    if (!_hasText) return; // 텍스트가 없으면 아무것도 하지 않음

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
                    focusNode: _focusNode,
                    style: const TextStyle(color: Colors.white),
                    decoration: _inputDecoration('Your preferred name'),
                    textInputAction: TextInputAction.done,
                    onChanged: _onTextChanged, // 텍스트 변경 감지
                    onTap: () {
                      // 텍스트 필드 탭 시 키보드 활성화 보장
                      if (!_focusNode.hasFocus) {
                        _focusNode.requestFocus();
                      }
                    },
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
                      icon: const Icon(Icons.shuffle, color: Colors.white60),
                      label: const Text(
                        'Generate Random Name',
                        style: TextStyle(
                          color: Colors.white60,
                          fontSize: 14,
                        ),
                      ),
                      style: TextButton.styleFrom(
                        backgroundColor:
                            Colors.black.withAlpha(102), // 블랙 배경으로 변경, 투명도 추가
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                          side: BorderSide(
                            color: Colors.white.withAlpha(128), // 테두리 투명도 조정
                            width: 1,
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
            onPressed: _hasText ? _handleContinue : null, // 텍스트가 있을 때만 활성화
            isOutlined: true,
            textColor: _hasText
                ? Colors.white
                : Colors.white.withAlpha(128), // 비활성화 시 투명도 적용
            borderColor: _hasText
                ? Colors.white
                : Colors.white.withAlpha(128), // 테두리도 투명도 적용
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
