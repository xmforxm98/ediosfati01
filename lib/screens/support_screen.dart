import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SupportScreen extends StatelessWidget {
  const SupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Support', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildContactSection(context),
            const SizedBox(height: 24),
            _buildFAQSection(),
            const SizedBox(height: 24),
            _buildHelpResourcesSection(context),
            const SizedBox(height: 24),
            _buildFeedbackSection(context),
          ],
        ),
      ),
    );
  }

  Widget _buildContactSection(BuildContext context) {
    return _buildSectionCard(
      context,
      title: 'Contact Us',
      icon: Icons.contact_support,
      children: [
        _buildContactTile(
          'Email Support',
          'Get help via email',
          Icons.email,
          'xmforxm98@gmail.com',
          () => _copyEmailToClipboard(context),
        ),
        const Divider(color: Colors.grey),
        _buildContactTile(
          'Response Time',
          'We typically respond within 24 hours',
          Icons.schedule,
          null,
          null,
        ),
      ],
    );
  }

  Widget _buildFAQSection() {
    return _buildSectionCard(
      null,
      title: 'Frequently Asked Questions',
      icon: Icons.help_outline,
      children: [
        _buildFAQTile(
          'How accurate is the Eidos analysis?',
          'Our analysis combines traditional Eastern philosophy with modern psychological insights. While results are based on established principles, they should be considered as guidance rather than absolute predictions.',
        ),
        _buildFAQTile(
          'Can I get multiple analysis reports?',
          'Yes, you can generate new analysis reports by updating your information in the onboarding flow. Each analysis is personalized based on your current data.',
        ),
        _buildFAQTile(
          'How is my personal data used?',
          'Your data is used solely to generate personalized analysis reports. We do not share your personal information with third parties. See our Privacy Policy for more details.',
        ),
        _buildFAQTile(
          'What do the Five Elements represent?',
          'The Five Elements (Wood, Fire, Earth, Metal, Water) represent different energy types and personality aspects in traditional Eastern philosophy. Your analysis shows the balance of these elements in your character.',
        ),
        _buildFAQTile(
          'How often should I check my report?',
          'Your core personality traits remain relatively stable, but you may find new insights by reviewing your report periodically or when facing important life decisions.',
        ),
      ],
    );
  }

  Widget _buildHelpResourcesSection(BuildContext context) {
    return _buildSectionCard(
      context,
      title: 'Help Resources',
      icon: Icons.library_books,
      children: [
        _buildResourceTile(
          'Understanding Five Elements',
          'Learn about Wood, Fire, Earth, Metal, and Water energies',
          Icons.nature,
          context,
        ),
        _buildResourceTile(
          'Interpreting Your Journey',
          'How to read your Daeun and yearly insights',
          Icons.timeline,
          context,
        ),
        _buildResourceTile(
          'Tarot Guidance',
          'Understanding your personalized tarot insights',
          Icons.auto_awesome,
          context,
        ),
        _buildResourceTile(
          'Relationship Compatibility',
          'Using insights for better relationships',
          Icons.favorite,
          context,
        ),
      ],
    );
  }

  Widget _buildFeedbackSection(BuildContext context) {
    return _buildSectionCard(
      context,
      title: 'Feedback & Suggestions',
      icon: Icons.feedback,
      children: [
        const Text(
          'We value your feedback to improve InnerFive. Please share your thoughts, suggestions, or report any issues.',
          style: TextStyle(color: Colors.white70, height: 1.5),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () => _showFeedbackDialog(context),
            icon: const Icon(Icons.send),
            label: const Text('Send Feedback'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.all(16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionCard(
    BuildContext? context, {
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[800]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: const Color(0xFF6366F1), size: 24),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildContactTile(
    String title,
    String subtitle,
    IconData icon,
    String? email,
    VoidCallback? onTap,
  ) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: Colors.white70),
      title: Text(title, style: const TextStyle(color: Colors.white)),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(subtitle, style: const TextStyle(color: Colors.white54)),
          if (email != null)
            Text(
              email,
              style: const TextStyle(
                color: Color(0xFF6366F1),
                fontWeight: FontWeight.w500,
              ),
            ),
        ],
      ),
      onTap: onTap,
    );
  }

  Widget _buildFAQTile(String question, String answer) {
    return Theme(
      data: ThemeData.dark(),
      child: ExpansionTile(
        title: Text(
          question,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              answer,
              style: const TextStyle(color: Colors.white70, height: 1.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResourceTile(
    String title,
    String description,
    IconData icon,
    BuildContext context,
  ) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: const Color(0xFF6366F1)),
      title: Text(title, style: const TextStyle(color: Colors.white)),
      subtitle: Text(
        description,
        style: const TextStyle(color: Colors.white54),
      ),
      trailing: const Icon(
        Icons.arrow_forward_ios,
        color: Colors.white54,
        size: 16,
      ),
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Detailed guides coming soon!'),
            backgroundColor: Colors.grey,
          ),
        );
      },
    );
  }

  void _copyEmailToClipboard(BuildContext context) {
    Clipboard.setData(const ClipboardData(text: 'xmforxm98@gmail.com'));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Email address copied to clipboard!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _showFeedbackDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.grey[900],
          title: const Text(
            'Send Feedback',
            style: TextStyle(color: Colors.white),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Please send your feedback to:',
                style: TextStyle(color: Colors.white70),
              ),
              const SizedBox(height: 8),
              const Text(
                'xmforxm98@gmail.com',
                style: TextStyle(
                  color: Color(0xFF6366F1),
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'We appreciate your feedback and will respond as soon as possible!',
                style: TextStyle(color: Colors.white70),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => _copyEmailToClipboard(context),
              child: const Text(
                'Copy Email',
                style: TextStyle(color: Color(0xFF6366F1)),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }
}
