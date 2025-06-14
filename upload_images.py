#!/usr/bin/env python3
"""
Firebase Storage에 이미지를 업로드하는 스크립트

사용법:
1. Firebase Admin SDK 설정:
   - Firebase Console > 프로젝트 설정 > 서비스 계정 > 새 비공개 키 생성
   - 다운로드한 JSON 파일을 이 스크립트와 같은 폴더에 'service-account-key.json'으로 저장

2. 필요한 패키지 설치:
   pip install firebase-admin

3. 스크립트 실행:
   python upload_images.py
"""

import os
import sys
from pathlib import Path
import firebase_admin
from firebase_admin import credentials, storage

# Firebase Admin SDK 초기화
def init_firebase():
    service_account_path = 'service-account-key.json'
    
    if not os.path.exists(service_account_path):
        print(f"❌ {service_account_path} 파일이 없습니다.")
        print("Firebase Console에서 서비스 계정 키를 다운로드하여 이 파일명으로 저장해주세요.")
        sys.exit(1)
    
    try:
        cred = credentials.Certificate(service_account_path)
        firebase_admin.initialize_app(cred, {
            'storageBucket': 'innerfive.firebasestorage.app'
        })
        print("✅ Firebase 초기화 완료")
        return storage.bucket()
    except Exception as e:
        print(f"❌ Firebase 초기화 실패: {e}")
        sys.exit(1)

def upload_image(bucket, local_path, remote_path):
    """이미지를 Firebase Storage에 업로드"""
    try:
        blob = bucket.blob(remote_path)
        blob.upload_from_filename(local_path)
        
        # 공개 읽기 권한 설정
        blob.make_public()
        
        print(f"✅ 업로드 완료: {local_path} -> {remote_path}")
        print(f"   URL: {blob.public_url}")
        return blob.public_url
    except Exception as e:
        print(f"❌ 업로드 실패 {local_path}: {e}")
        return None

def main():
    print("🚀 Firebase Storage 이미지 업로드 시작")
    
    # Firebase 초기화
    bucket = init_firebase()
    
    # 이미지 폴더 경로
    images_dir = Path("assets/images")
    
    if not images_dir.exists():
        print(f"❌ 이미지 폴더가 없습니다: {images_dir}")
        sys.exit(1)
    
    # 업로드할 이미지 목록
    image_files = [
        'login_bg.png',
        'name_input_bg.png',
        'birth_time.png',
        'second_bg.png',
        'city_bg.png',
        'birth_input_bg.png',
        'continue_to.png',
        'loading_bg.png',
        'gender_bg.png',
        'input_bg.png',
    ]
    
    uploaded_urls = {}
    total_size = 0
    
    print(f"\n📁 {len(image_files)}개 이미지 업로드 중...")
    
    for image_file in image_files:
        local_path = images_dir / image_file
        
        if not local_path.exists():
            print(f"⚠️  파일이 없습니다: {local_path}")
            continue
        
        # 파일 크기 확인
        file_size = local_path.stat().st_size
        total_size += file_size
        print(f"\n📷 {image_file} ({file_size / 1024 / 1024:.2f}MB)")
        
        # Firebase Storage에 업로드
        remote_path = f"images/{image_file}"
        url = upload_image(bucket, str(local_path), remote_path)
        
        if url:
            uploaded_urls[image_file.split('.')[0]] = url
    
    print(f"\n🎉 업로드 완료!")
    print(f"📊 총 용량: {total_size / 1024 / 1024:.2f}MB")
    print(f"📦 업로드된 파일: {len(uploaded_urls)}개")
    
    # URL 정보 출력
    print("\n📋 업로드된 이미지 URL:")
    print("=" * 80)
    for name, url in uploaded_urls.items():
        print(f"{name}: {url}")
    
    # image_service.dart 업데이트용 코드 생성
    print("\n🔧 image_service.dart 업데이트용 코드:")
    print("=" * 80)
    print("static const Map<String, String> _imageUrls = {")
    for name, url in uploaded_urls.items():
        print(f"  '{name}': '{url}',")
    print("};")

if __name__ == "__main__":
    main() 