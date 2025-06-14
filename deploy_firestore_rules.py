#!/usr/bin/env python3
"""
Firebase Firestore Security Rules 배포 스크립트
"""

import firebase_admin
from firebase_admin import credentials, firestore
import subprocess
import os

def deploy_firestore_rules():
    """Firestore Security Rules 배포"""
    
    # Firebase CLI를 사용하여 rules 배포
    try:
        print("🔧 Deploying Firestore Security Rules...")
        
        # firestore.rules 파일이 존재하는지 확인
        if not os.path.exists('firestore.rules'):
            print("❌ firestore.rules 파일을 찾을 수 없습니다.")
            return False
        
        # Firebase CLI로 rules 배포
        result = subprocess.run(['firebase', 'deploy', '--only', 'firestore:rules'], 
                              capture_output=True, text=True)
        
        if result.returncode == 0:
            print("✅ Firestore Security Rules가 성공적으로 배포되었습니다!")
            print(result.stdout)
            return True
        else:
            print("❌ Firestore Security Rules 배포 실패:")
            print(result.stderr)
            return False
            
    except FileNotFoundError:
        print("❌ Firebase CLI가 설치되지 않았습니다.")
        print("다음 명령어로 설치하세요: npm install -g firebase-tools")
        return False
    except Exception as e:
        print(f"❌ 배포 중 오류 발생: {e}")
        return False

def check_rules_content():
    """Rules 파일 내용 확인"""
    try:
        with open('firestore.rules', 'r', encoding='utf-8') as f:
            content = f.read()
            
        print("📋 현재 Firestore Security Rules:")
        print("=" * 50)
        print(content)
        print("=" * 50)
        
        return True
    except FileNotFoundError:
        print("❌ firestore.rules 파일을 찾을 수 없습니다.")
        return False

if __name__ == "__main__":
    print("🚀 Firebase Firestore Security Rules 배포 스크립트")
    print()
    
    # Rules 내용 확인
    if check_rules_content():
        print()
        
        # 사용자 확인
        confirm = input("위의 rules를 배포하시겠습니까? (y/N): ").strip().lower()
        
        if confirm in ['y', 'yes']:
            deploy_firestore_rules()
        else:
            print("⏹️  배포가 취소되었습니다.")
    else:
        print("Rules 파일 문제로 배포를 중단합니다.") 