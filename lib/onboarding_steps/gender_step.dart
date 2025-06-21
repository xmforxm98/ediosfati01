import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
// import 'package:innerfive/gender_selection_screen.dart';
import 'package:innerfive/models/user_data.dart';
import 'package:innerfive/widgets/animation_extensions.dart';
import 'package:innerfive/widgets/custom_button.dart';
import 'package:innerfive/widgets/custom_error_message.dart';

class GenderStep extends StatefulWidget {
  final UserData userData;
  final VoidCallback onNext;

  const GenderStep({super.key, required this.userData, required this.onNext});

  @override
  State<GenderStep> createState() => _GenderStepState();
}

class _GenderStepState extends State<GenderStep> {
  Gender? _selectedGender;

  @override
  void initState() {
    super.initState();
    _selectedGender = widget.userData.gender;

    // 화면이 로드될 때 키패드 숨기기
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        FocusScope.of(context).unfocus();
        // 추가적으로 시스템 UI 모드 설정
        FocusManager.instance.primaryFocus?.unfocus();
      }
    });
  }

  void _handleNext() {
    if (_selectedGender == null) return; // 성별이 선택되지 않으면 아무것도 하지 않음

    widget.userData.gender = _selectedGender;
    widget.onNext();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Gender 화면에서만 키패드 숨기기 (텍스트 입력이 없으므로)
        FocusScope.of(context).unfocus();
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Gender information has a subtle but significant impact on the flow and interpretation of destiny. This is because even with the same Four Pillars of Destiny, the flow of Great Fortune can differ based on gender.',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                      height: 1.5,
                    ),
                  ).animateOnPageLoad(delay: 400.ms),
                  const SizedBox(height: 30),
                  const Text(
                    'Next Step: Your Gender\nAre you male or female?',
                    style: TextStyle(
                      fontSize: 22,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ).animateOnPageLoad(delay: 600.ms),
                  const SizedBox(height: 20),
                  _buildGenderButtons().animateOnPageLoad(delay: 800.ms),
                  const SizedBox(height: 30),
                  _buildTransgenderInfo().animateOnPageLoad(delay: 1000.ms),
                ],
              ),
            ),
            const SizedBox(height: 30),
            CustomButton(
              text: 'Next',
              onPressed: _selectedGender != null
                  ? _handleNext
                  : null, // 성별이 선택되었을 때만 활성화
              isOutlined: true,
              textColor: _selectedGender != null
                  ? Colors.white
                  : Colors.white.withAlpha(128), // 비활성화 시 투명도 적용
              borderColor: _selectedGender != null
                  ? Colors.white
                  : Colors.white.withAlpha(128), // 테두리도 투명도 적용
            ).animateOnPageLoad(delay: 1200.ms),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildGenderButtons() {
    return Row(
      children: [
        Expanded(
          child: CustomButton(
            text: 'Male',
            onPressed: () => setState(() => _selectedGender = Gender.male),
            isOutlined: _selectedGender != Gender.male,
            backgroundColor: Colors.white,
            textColor:
                _selectedGender == Gender.male ? Colors.black : Colors.white,
          ),
        ),
        const SizedBox(width: 20),
        Expanded(
          child: CustomButton(
            text: 'Female',
            onPressed: () => setState(() => _selectedGender = Gender.female),
            isOutlined: _selectedGender != Gender.female,
            backgroundColor: Colors.white,
            textColor:
                _selectedGender == Gender.female ? Colors.black : Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildTransgenderInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black.withAlpha(128),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withAlpha(64)),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Are you transgender?',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          SizedBox(height: 10),
          Text(
            "Eidos Fati analyzes destiny based on your assigned (biological) sex at birth. This is because certain elements of the Four Pillars of Destiny, such as the flow of Great Fortune, are established based on the fundamental principles of Myeongrihak. For your journey of true self-understanding, we would be grateful if you select your sex at birth, regardless of your current gender identity.",
            style: TextStyle(color: Colors.white70, fontSize: 13, height: 1.4),
          ),
        ],
      ),
    );
  }
}
