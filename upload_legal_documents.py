#!/usr/bin/env python3
"""
Firebase Firestore에 Terms of Use와 Privacy Policy 문서를 업로드하는 스크립트
"""

import firebase_admin
from firebase_admin import credentials, firestore
import json
from datetime import datetime

def initialize_firebase():
    """Firebase 초기화"""
    if not firebase_admin._apps:
        cred = credentials.Certificate('service-account-key.json')
        firebase_admin.initialize_app(cred)
    
    return firestore.client()

def upload_legal_documents():
    """Terms of Use와 Privacy Policy를 Firestore에 업로드"""
    
    db = initialize_firebase()
    
    # Terms of Use 내용
    terms_of_use = """Eidos Fati App Terms of Use
Welcome! Thank you for using Eidos Fati. These Terms of Use govern the relationship between you and Eidos Fati regarding your use of the Eidos Fati app (hereinafter referred to as the "App"). Please read these Terms of Use carefully before using the App.

1. Acceptance of Terms
By installing or using the App, you agree to be bound by these Terms of Use and our Privacy Policy. If you do not agree to these terms, please do not use the App.

2. Service Provision
Eidos Fati provides services that help users explore and interact with information for specific purposes. The content and features of the service may change through App updates.

3. User Accounts
Account Creation: You may be required to create an account to use certain features. You are responsible for maintaining the security of your account information (e.g., username, password).
Account Responsibility: You are responsible for all activities that occur under your account. You must notify Eidos Fati immediately if you suspect any unauthorized use of your account.

4. Account Deletion
User-Initiated Deletion: You have the right to delete your account at any time through the App's account settings. When you delete your account:
- Your personal data will be permanently deleted from our servers within 30 days
- Your usage history and generated content will be anonymized or deleted
- Some information may be retained as required by law or for legitimate business purposes
- The deletion process is irreversible and cannot be undone

Account Deletion Process: To delete your account, go to Settings > Account > Delete Account in the App, or contact us at xmforxm98@gmail.com. We will confirm your identity before processing the deletion request.

5. User Conduct
Lawful Use: You must use the App in compliance with all applicable laws and regulations.
Prohibited Actions: The following actions are prohibited, including but not limited to:
Posting or sharing illegal or harmful content.
Harassing or threatening other users.
Attempting to interfere with or damage the functionality of the App.
Infringing intellectual property rights.

6. Intellectual Property Rights
All content, features, and intellectual property (trademarks, logos, software, etc.) within the App are owned by Eidos Fati or its licensors and are protected by relevant laws. Unauthorized use, reproduction, or distribution of these without the express written consent of Eidos Fati is prohibited.

7. Disclaimer of Warranties
Eidos Fati does not guarantee that the App will always operate without errors or be provided without interruption. Eidos Fati is not liable for any direct, indirect, incidental, or consequential damages arising from your use of the App.

8. Changes to Terms
Eidos Fati reserves the right to modify these Terms of Use at any time. Changes will be notified through:
- In-app notifications or announcements
- Email notifications to your registered email address
- Updates to this document with the revision date
- Push notifications for significant changes

Continued use of the App after notification of changes constitutes acceptance of the modified terms. If you do not agree to the modified terms, you must stop using the App and may delete your account.

9. Termination
Eidos Fati may terminate your access to the App at any time without prior notice if you violate these terms or are involved in illegal activities. Upon termination, your account and associated data will be handled according to our data retention policies.

10. Governing Law
These Terms of Use shall be governed by and construed in accordance with the laws of the Republic of Korea. Any disputes arising in connection with these terms shall be subject to the exclusive jurisdiction of the courts of the Republic of Korea.

11. Contact Us
If you have any questions about these Terms of Use, please contact us at xmforxm98@gmail.com."""

    # Privacy Policy 내용
    privacy_policy = """Eidos Fati App Privacy Policy
Eidos Fati highly values the privacy of its users and complies with relevant laws and regulations. This Privacy Policy describes the information collected, used, and disclosed through the Eidos Fati app (hereinafter referred to as the "App").

1. Information We Collect
Eidos Fati may collect the following information to provide its services:

Account Information: Information you provide when creating an account, such as username, email address, and password (stored in an encrypted form).

Usage Information: Statistical information for service improvement, such as how you use the App, pages visited, content interacted with, and time spent on the App. This information is generally collected in a non-personally identifiable form.

Device Information: Information about your App usage environment, such as device model, operating system version, unique device identifiers, and IP address.

Optional Information: Additional information voluntarily provided by the user (e.g., profile picture, personal settings, birth date, birth time, city, gender, nickname for personalized services).

Firebase Data Collection: We use Google Firebase services to provide and improve our App. Firebase collects the following data:
- Firebase Authentication: Email addresses, encrypted passwords, user IDs, authentication tokens
- Firebase Firestore: User profile data, app usage data, generated content, analysis results
- Firebase Analytics: App usage patterns, screen views, user engagement metrics, device information, crash reports
- Firebase Cloud Messaging: Device tokens for push notifications
- Firebase Performance Monitoring: App performance metrics, network request data, trace data
- Firebase Crashlytics: Crash reports, device state information, custom logs

2. How We Collect Information
Direct Input from User: Information directly entered by the user during registration, profile setup, etc.

Automatic Collection: Information automatically generated and collected during App usage (e.g., log data, cookies, or similar technologies). This includes information collected via Firebase services.

Third-Party SDK Collection: Data collected through integrated third-party services including Firebase, advertising SDKs, and analytics tools.

3. Purpose of Information Use
The collected information is used for the following purposes:

Service Provision: To provide core App functionalities and services, and to enhance user experience.
Account Management: To manage user accounts and perform identity verification.
Service Improvement and App Analytics: To improve the performance, functionality, and usability of the service by analyzing usage patterns, and to analyze app usage data using Firebase Analytics.
Customer Support: To respond to user inquiries and assist with problem resolution.
Compliance with Legal Obligations: To comply with obligations required by relevant laws and regulations.
Personalized Content Delivery: To provide personalized content and recommendations based on user preferences and usage patterns.
Security and Fraud Prevention: To protect the App and users from security threats and fraudulent activities.
Push Notifications: To send important updates, personalized content, and service-related notifications.

4. Information Sharing and Third-Party Disclosure
Eidos Fati does not provide or share your personal information with third parties without your consent. However, exceptions apply in the following cases:

Legal Requirements: When required by law, such as court orders or requests from investigative agencies.

Service Provision Purposes: To provide necessary minimum information to third-party service providers who perform services on behalf of Eidos Fati, including:
- Google Firebase (Cloud hosting, analytics, authentication, database services)
- Cloud hosting providers
- Analytics service providers
- Customer support platforms

In such cases, these providers process the information according to Eidos Fati's instructions and comply with information protection obligations.

Business Transfer: In the event of a merger, acquisition, or asset sale, personal information may be transferred in accordance with relevant laws.

5. Data Retention and Destruction
Data Retention Periods:
- Account Information: Retained while your account is active and for 30 days after account deletion
- Usage Analytics Data: Retained for up to 2 years for service improvement purposes
- Customer Support Communications: Retained for up to 3 years for quality assurance
- Legal Compliance Data: Retained as required by applicable laws (typically 5-7 years)
- Marketing Communications: Retained until you unsubscribe or withdraw consent

Destruction Procedure: 
- Personal information is automatically deleted after the retention period expires
- Upon account deletion, personal data is permanently removed within 30 days
- Electronic files are deleted using secure deletion methods that prevent data recovery
- Physical documents are destroyed by shredding or incineration
- Users will be notified of significant data processing activities and can request deletion status updates

6. User Rights and How to Exercise Them
Users have the following rights regarding their personal information:

Access and View: Request access to and viewing of your personal information
- How to exercise: Send a request to xmforxm98@gmail.com with your account information
- Response time: Within 30 days of request

Correction: Request correction of personal information if there are errors
- How to exercise: Update information in App settings or contact xmforxm98@gmail.com
- Response time: Immediate for self-service updates, within 15 days for email requests

Deletion: Request deletion of personal information under certain conditions
- How to exercise: Use the "Delete Account" feature in App settings or contact xmforxm98@gmail.com
- Response time: Account deletion completed within 30 days

Processing Suspension: Request suspension of personal information processing
- How to exercise: Contact xmforxm98@gmail.com with specific processing activities to suspend
- Response time: Within 15 days of request

Withdrawal of Consent: Withdraw consent for personal information collection and use at any time
- How to exercise: Adjust privacy settings in the App or contact xmforxm98@gmail.com
- Response time: Immediate for App settings, within 15 days for email requests

Data Portability: Request a copy of your data in a machine-readable format
- How to exercise: Contact xmforxm98@gmail.com
- Response time: Within 30 days of request

To exercise these rights, please contact us at xmforxm98@gmail.com with your account information and specific request details.

7. iOS App Tracking Transparency (ATT) Policy
For iOS users, we comply with Apple's App Tracking Transparency framework:

Tracking Permission: We may request permission to track your activity across other companies' apps and websites for personalized advertising purposes. You can grant or deny this permission when prompted.

What We Track: With your permission, we may track:
- Cross-app usage patterns for personalized content recommendations
- Advertising interaction data for improving ad relevance
- Device identifiers for analytics and advertising purposes

Your Control: You can change your tracking preferences at any time by:
- Going to iOS Settings > Privacy & Security > Tracking
- Toggling permission for Eidos Fati
- Managing advertising preferences in the App settings

No Tracking Without Permission: If you deny tracking permission, we will not access your device's advertising identifier or track your activity across other apps and websites for advertising purposes.

8. International Data Transfers
Your information may be transferred to and processed in countries other than your country of residence. We ensure appropriate safeguards are in place to protect your information during such transfers, including:
- Using standard contractual clauses approved by relevant authorities
- Ensuring third-party services comply with applicable data protection laws
- Regular security assessments of international data processing partners

9. Security
Eidos Fati implements comprehensive technical and administrative security measures:

Technical Measures:
- End-to-end encryption for sensitive data transmission
- Secure data storage with industry-standard encryption
- Regular security audits and vulnerability assessments
- Automated threat detection and response systems

Administrative Measures:
- Staff training on data protection and security protocols
- Access controls limiting data access to authorized personnel only
- Regular security policy updates and compliance monitoring
- Incident response procedures for potential security breaches

10. Children's Privacy
Our App is not intended for children under 13 years of age. We do not knowingly collect personal information from children under 13. If we become aware that we have collected personal information from a child under 13, we will take steps to delete such information promptly.

11. Changes to Privacy Policy
We may update this Privacy Policy from time to time. Changes will be communicated through:
- In-app notifications with summary of key changes
- Email notifications to registered users
- Updated version posted in the App with revision date
- Push notifications for significant policy changes

We encourage you to review this Privacy Policy periodically. Significant changes will be notified at least 30 days before they take effect. Continued use of the App after the effective date constitutes acceptance of the updated Privacy Policy.

12. Regional Compliance
We comply with applicable regional privacy laws, including:
- General Data Protection Regulation (GDPR) for EU users
- California Consumer Privacy Act (CCPA) for California residents
- Personal Information Protection Act for Korean users
- Other applicable local privacy regulations

Regional-specific rights and procedures are available upon request.

13. Contact Us
For any questions about this Privacy Policy or to exercise your privacy rights:

Email: xmforxm98@gmail.com
Response Time: We aim to respond to all privacy-related inquiries within 30 days
Language: Inquiries can be made in English or Korean

For urgent privacy concerns or data breach notifications, please mark your email as "URGENT - Privacy" in the subject line."""

    try:
        # Terms of Use 문서 업로드
        terms_doc_ref = db.collection('legal_documents').document('terms_of_use')
        terms_doc_ref.set({
            'title': 'Terms of Use',
            'content': terms_of_use,
            'version': '2.0',
            'updated_at': datetime.now(),
            'language': 'en',
            'active': True
        })
        print("✅ Terms of Use 업로드 완료")

        # Privacy Policy 문서 업로드
        privacy_doc_ref = db.collection('legal_documents').document('privacy_policy')
        privacy_doc_ref.set({
            'title': 'Privacy Policy',
            'content': privacy_policy,
            'version': '2.0',
            'updated_at': datetime.now(),
            'language': 'en',
            'active': True
        })
        print("✅ Privacy Policy 업로드 완료")

        print("\n🎉 모든 법적 문서가 Firestore에 성공적으로 업로드되었습니다!")
        print("📍 컬렉션: legal_documents")
        print("📄 문서: terms_of_use, privacy_policy")

    except Exception as e:
        print(f"❌ 업로드 중 오류 발생: {e}")

if __name__ == "__main__":
    upload_legal_documents() 