import 'package:flutter/material.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Privacy Policy'),
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: const SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Text('''Eidos Fati App Privacy Policy
Eidos Fati highly values the privacy of its users and complies with relevant laws and regulations. This Privacy Policy describes the information collected, used, and disclosed through the Eidos Fati app (hereinafter referred to as the "App").

1. Information We Collect
Eidos Fati may collect the following information to provide its services:

Account Information: Information you provide when creating an account, such as username, email address, and password (stored in an encrypted form).
Usage Information: Statistical information for service improvement, such as how you use the App, pages visited, content interacted with, and time spent on the App. This information is generally collected in a non-personally identifiable form.
Device Information: Information about your App usage environment, such as device model, operating system version, unique device identifiers, and IP address.
Optional Information: Additional information voluntarily provided by the user (e.g., profile picture, personal settings).
2. How We Collect Information
Direct Input from User: Information directly entered by the user during registration, profile setup, etc.
Automatic Collection: Information automatically generated and collected during App usage (e.g., log data, cookies, or similar technologies). This includes information collected via Firebase.
3. Purpose of Information Use
The collected information is used for the following purposes:

Service Provision: To provide core App functionalities and services, and to enhance user experience.
Account Management: To manage user accounts and perform identity verification.
Service Improvement and App Analytics: To improve the performance, functionality, and usability of the service by analyzing usage patterns, and to analyze app usage data using Firebase.
Customer Support: To respond to user inquiries and assist with problem resolution.
Compliance with Legal Obligations: To comply with obligations required by relevant laws and regulations.
Personalized Content Delivery: To provide personalized content and advertisements based on user interests (only with user consent).
4. Information Sharing and Third-Party Disclosure
Eidos Fati does not provide or share your personal information with third parties without your consent. However, exceptions apply in the following cases:

Legal Requirements: When required by law, such as court orders or requests from investigative agencies.
Service Provision Purposes: To provide necessary minimum information to third-party service providers (e.g., cloud hosting services, Firebase) who perform services on behalf of Eidos Fati. In such cases, these providers process the information according to Eidos Fati's instructions and comply with information protection obligations.
Business Transfer: In the event of a merger, acquisition, or asset sale, personal information may be transferred in accordance with relevant laws.
5. Storage and Destruction of Personal Information
Storage Period: User personal information is stored for the duration of service use and for the period required by law or until the purpose of collection and use is achieved.
Destruction Procedure: Personal information for which the purpose has been achieved will be destroyed without delay. Information in electronic file format is deleted using a technical method that prevents its reproduction, and information in paper document format is destroyed by shredding or incineration.
6. User Rights
Users have the following rights regarding their personal information:

Access and View: The right to request access to and viewing of their personal information.
Correction: The right to request correction of personal information if there are errors.
Deletion: The right to request deletion of personal information under certain conditions.
Processing Suspension: The right to request suspension of personal information processing.
Withdrawal of Consent: The right to withdraw consent for personal information collection and use at any time.
To exercise these rights, please contact us at xmforxm98@gmail.com.

7. Security
Eidos Fati makes technical and administrative efforts to protect user personal information. Reasonable security measures are taken to prevent unauthorized access, disclosure, use, alteration, or destruction of personal information.

8. Changes to Privacy Policy
Eidos Fati may change this Privacy Policy. Changes will be notified to users through in-app announcements or other reasonable methods.

9. Contact Us
If you have any questions about this Privacy Policy, please contact us at xmforxm98@gmail.com.
''', style: TextStyle(fontSize: 16, color: Colors.white)),
      ),
    );
  }
}
