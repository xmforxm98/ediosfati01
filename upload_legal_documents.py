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
If you have any questions about these Terms of Use, please contact us at xmforxm98@gmail.com."""

    # Privacy Policy 내용
    privacy_policy = """Eidos Fati App Privacy Policy
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
If you have any questions about this Privacy Policy, please contact us at xmforxm98@gmail.com."""

    try:
        # Terms of Use 문서 업로드
        terms_doc_ref = db.collection('legal_documents').document('terms_of_use')
        terms_doc_ref.set({
            'title': 'Terms of Use',
            'content': terms_of_use,
            'version': '1.0',
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
            'version': '1.0',
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