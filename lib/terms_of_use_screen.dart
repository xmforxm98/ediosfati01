import 'package:flutter/material.dart';

class TermsOfUseScreen extends StatelessWidget {
  const TermsOfUseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Terms of Use'),
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: const SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Text('''Eidos Fati App Terms of Use
Welcome! Thank you for using Eidos Fati. These Terms of Use govern the relationship between you and Eidos Fati regarding your use of the Eidos Fati app (hereinafter referred to as the "App"). Please read these Terms of Use carefully before using the App.

1. Acceptance of Terms
By installing or using the App, you agree to be bound by these Terms of Use and our Privacy Policy. If you do not agree to these terms, please do not use the App.

2. Service Provision
Eidos Fati provides services that help users explore and interact with information for specific purposes. The content and features of the service may change through App updates.

3. User Accounts
Account Creation: You may be required to create an account to use certain features. You are responsible for maintaining the security of your account information (e.g., username, password).
Account Responsibility: You are responsible for all activities that occur under your account. You must notify Eidos Fati immediately if you suspect any unauthorized use of your account.
4. User Conduct
Lawful Use: You must use the App in compliance with all applicable laws and regulations.
Prohibited Actions: The following actions are prohibited, including but not limited to:
Posting or sharing illegal or harmful content.
Harassing or threatening other users.
Attempting to interfere with or damage the functionality of the App.
Infringing intellectual property rights.
5. Intellectual Property Rights
All content, features, and intellectual property (trademarks, logos, software, etc.) within the App are owned by Eidos Fati or its licensors and are protected by relevant laws. Unauthorized use, reproduction, or distribution of these without the express written consent of Eidos Fati is prohibited.

6. Disclaimer of Warranties
Eidos Fati does not guarantee that the App will always operate without errors or be provided without interruption. Eidos Fati is not liable for any direct, indirect, incidental, or consequential damages arising from your use of the App.

7. Changes to Terms
Eidos Fati reserves the right to modify these Terms of Use at any time. Changes will be notified through in-app announcements or email. If you do not agree to the modified terms, you must stop using the App.

8. Termination
Eidos Fati may terminate your access to the App at any time without prior notice if you violate these terms or are involved in illegal activities.

9. Governing Law
These Terms of Use shall be governed by and construed in accordance with the laws of the Republic of Korea. Any disputes arising in connection with these terms shall be subject to the exclusive jurisdiction of the courts of the Republic of Korea.

10. Contact Us
If you have any questions about these Terms of Use, please contact us at xmforxm98@gmail.com.
''', style: TextStyle(fontSize: 16, color: Colors.white)),
      ),
    );
  }
}
