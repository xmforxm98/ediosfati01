import 'package:flutter/material.dart';
import 'package:innerfive/screens/onboarding/onboarding_flow_screen.dart';

class ProfileHeader extends StatelessWidget {
  final Map<String, dynamic>? userData;
  final String? eidosTitle;
  final Function onUpdate;

  const ProfileHeader({
    super.key,
    required this.userData,
    required this.eidosTitle,
    required this.onUpdate,
  });

  String _getInitials(String? name) {
    if (name == null || name.isEmpty) return '';
    final parts = name.split(' ');
    if (parts.length > 1) {
      return (parts.first.isNotEmpty ? parts.first[0] : '') +
          (parts.last.isNotEmpty ? parts.last[0] : '');
    }
    return parts.first.isNotEmpty ? parts.first[0] : '';
  }

  String _formatBirthDate(dynamic birthDate) {
    if (birthDate == null || birthDate == '' || birthDate == 'null') {
      return 'Not Set';
    }
    return birthDate.toString();
  }

  String _formatBirthTime(dynamic birthTime) {
    if (birthTime == null ||
        birthTime == '' ||
        birthTime == 'null' ||
        birthTime == 'null:null') {
      return 'Not Set';
    }
    return birthTime.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.grey[900]?.withOpacity(0.8),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.grey[800],
                    child: Text(
                      _getInitials(
                          userData?['nickname'] ?? userData?['displayName']),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          userData?['nickname'] ??
                              userData?['displayName'] ??
                              'No Name',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          eidosTitle ?? 'The Essence of Your Eidos',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const Divider(color: Colors.white24),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Column(
                    children: [
                      const Text(
                        'Birth Date',
                        style: TextStyle(color: Colors.white70, fontSize: 14),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _formatBirthDate(userData?['birthDate']),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      const Text(
                        'Birth Time',
                        style: TextStyle(color: Colors.white70, fontSize: 14),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _formatBirthTime(userData?['birthTime']),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              Navigator.of(context)
                  .push(
                    MaterialPageRoute(
                      builder: (context) => const OnboardingFlowScreen(),
                    ),
                  )
                  .then((_) => onUpdate());
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white.withOpacity(0.15),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(40),
              ),
              elevation: 0,
            ),
            child: const Text(
              'Update My Details',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
    );
  }
}
