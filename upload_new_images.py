#!/usr/bin/env python3
"""
새로운 이미지를 Firebase Storage에 업로드하는 개선된 스크립트

사용법:
1. assets/images/ 폴더에 새 이미지 추가
2. python upload_new_images.py
3. 출력된 코드를 image_service.dart에 복사
"""

import os
import sys
from pathlib import Path
import firebase_admin
from firebase_admin import credentials, storage
import json

# Firebase Admin SDK 초기화
def init_firebase():
    service_account_path = 'service-account-key.json'
    
    if not os.path.exists(service_account_path):
        print(f"❌ {service_account_path} 파일이 없습니다.")
        sys.exit(1)
    
    # 이미 초기화되었는지 확인
    if not firebase_admin._apps:
        try:
            cred = credentials.Certificate(service_account_path)
            firebase_admin.initialize_app(cred, {
                'storageBucket': 'innerfive.firebasestorage.app'
            })
            print("✅ Firebase 초기화 완료")
        except Exception as e:
            print(f"❌ Firebase 초기화 실패: {e}")
            sys.exit(1)
    
    return storage.bucket()

def get_existing_images(bucket):
    """Firebase Storage에 이미 있는 이미지 목록 가져오기"""
    existing = set()
    blobs = bucket.list_blobs(prefix='images/')
    for blob in blobs:
        filename = blob.name.replace('images/', '').replace('.png', '').replace('.jpg', '').replace('.jpeg', '')
        existing.add(filename)
    return existing

def upload_image(bucket, local_path, remote_path):
    """이미지를 Firebase Storage에 업로드"""
    try:
        blob = bucket.blob(remote_path)
        blob.upload_from_filename(local_path)
        blob.make_public()
        
        print(f"✅ 업로드: {local_path.name} -> {remote_path}")
        return blob.public_url
    except Exception as e:
        print(f"❌ 업로드 실패 {local_path}: {e}")
        return None

def scan_local_images():
    """로컬 이미지 폴더 스캔"""
    images_dir = Path("assets/images")
    if not images_dir.exists():
        print(f"❌ 이미지 폴더가 없습니다: {images_dir}")
        return []
    
    # 지원하는 이미지 확장자
    extensions = ['.png', '.jpg', '.jpeg', '.gif', '.webp']
    images = []
    
    for ext in extensions:
        images.extend(images_dir.glob(f'*{ext}'))
    
    return images

def generate_dart_code(all_urls):
    """Dart 코드 생성"""
    print("\n🔧 image_service.dart 업데이트용 코드:")
    print("=" * 80)
    print("static const Map<String, String> _imageUrls = {")
    for name, url in sorted(all_urls.items()):
        print(f"  '{name}': '{url}',")
    print("};")

def save_config(all_urls):
    """이미지 URL 설정을 JSON 파일로 저장"""
    config_path = Path("image_urls.json")
    with open(config_path, 'w', encoding='utf-8') as f:
        json.dump(all_urls, f, indent=2, ensure_ascii=False)
    print(f"\n💾 설정 저장됨: {config_path}")

def main():
    print("🚀 새로운 이미지 업로드 시작")
    
    # Firebase 초기화
    bucket = init_firebase()
    
    # 기존 이미지 확인
    existing_images = get_existing_images(bucket)
    print(f"📦 기존 이미지: {len(existing_images)}개")
    
    # 로컬 이미지 스캔
    local_images = scan_local_images()
    print(f"📁 로컬 이미지: {len(local_images)}개")
    
    if not local_images:
        print("❌ 업로드할 이미지가 없습니다.")
        return
    
    new_uploads = []
    all_urls = {}
    total_size = 0
    
    for image_path in local_images:
        # 확장자 제거한 이름
        image_name = image_path.stem
        
        # 파일 크기
        file_size = image_path.stat().st_size
        total_size += file_size
        
        # 새 이미지인지 확인
        is_new = image_name not in existing_images
        status = "🆕 새 이미지" if is_new else "🔄 업데이트"
        
        print(f"\n{status}: {image_path.name} ({file_size / 1024 / 1024:.2f}MB)")
        
        # 업로드
        remote_path = f"images/{image_path.name}"
        url = upload_image(bucket, image_path, remote_path)
        
        if url:
            all_urls[image_name] = url
            if is_new:
                new_uploads.append(image_name)
    
    print(f"\n🎉 업로드 완료!")
    print(f"📊 총 용량: {total_size / 1024 / 1024:.2f}MB")
    print(f"🆕 새 이미지: {len(new_uploads)}개")
    print(f"📦 전체 이미지: {len(all_urls)}개")
    
    if new_uploads:
        print(f"\n🆕 새로 추가된 이미지:")
        for name in new_uploads:
            print(f"  - {name}")
    
    # Dart 코드 생성
    generate_dart_code(all_urls)
    
    # 설정 저장
    save_config(all_urls)
    
    print(f"\n📝 다음 단계:")
    print(f"1. 위의 코드를 lib/services/image_service.dart의 _imageUrls에 복사")
    print(f"2. 새 이미지를 사용하는 코드에서 ImageService.getImageUrl('이미지명') 호출")

if __name__ == "__main__":
    main() 