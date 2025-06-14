#!/usr/bin/env python3
"""
단일 이미지를 Firebase Storage에 업로드하는 스크립트
"""

import firebase_admin
from firebase_admin import credentials, storage
import os
import argparse

def initialize_firebase():
    """Firebase 초기화"""
    if not firebase_admin._apps:
        cred = credentials.Certificate('service-account-key.json')
        firebase_admin.initialize_app(cred, {
            'storageBucket': 'innerfive.firebasestorage.app'
        })
    
    return storage.bucket()

def upload_image(local_path, storage_path):
    """
    이미지를 Firebase Storage에 업로드
    
    Args:
        local_path: 로컬 이미지 파일 경로
        storage_path: Firebase Storage에 저장될 경로
    """
    try:
        bucket = initialize_firebase()
        
        print(f"📤 업로드 시작: {local_path} -> {storage_path}")
        
        # 파일을 Firebase Storage에 업로드
        blob = bucket.blob(storage_path)
        blob.upload_from_filename(local_path)
        
        # 공개 URL 생성
        blob.make_public()
        public_url = blob.public_url
        
        print(f"✅ 업로드 완료!")
        print(f"📍 Storage 경로: {storage_path}")
        print(f"🌐 공개 URL: {public_url}")
        
        return public_url
        
    except Exception as e:
        print(f"❌ 업로드 실패: {e}")
        return None

def main():
    parser = argparse.ArgumentParser(description='단일 이미지 Firebase Storage 업로드')
    parser.add_argument('input', help='업로드할 이미지 파일 경로')
    parser.add_argument('-p', '--path', help='Firebase Storage 경로 (기본값: backgrounds/파일명)')
    
    args = parser.parse_args()
    
    if not os.path.exists(args.input):
        print(f"❌ 입력 파일을 찾을 수 없습니다: {args.input}")
        return
    
    # Storage 경로 설정
    if args.path:
        storage_path = args.path
    else:
        filename = os.path.basename(args.input)
        storage_path = f"backgrounds/{filename}"
    
    # 업로드 실행
    upload_image(args.input, storage_path)

if __name__ == "__main__":
    main() 