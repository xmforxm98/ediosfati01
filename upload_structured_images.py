#!/usr/bin/env python3
"""
폴더 구조를 지원하는 Firebase Storage 이미지 업로드 스크립트

폴더 구조:
assets/images/
├── backgrounds/  # 배경화면들
├── icons/       # 아이콘들  
├── ui/          # UI 요소들
└── characters/  # 캐릭터들 (향후 추가)

사용법:
1. assets/images/ 하위 폴더에 이미지 추가
2. python upload_structured_images.py
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
    """Firebase Storage에 이미 있는 이미지 목록 가져오기 (폴더 구조 포함)"""
    existing = {}
    
    # 모든 블롭을 스캔
    blobs = bucket.list_blobs()
    for blob in blobs:
        if blob.name.startswith('images/'):
            # 폴더 구조 파싱: images/backgrounds/login_bg.png
            parts = blob.name.split('/')
            if len(parts) >= 3:
                folder = parts[1]  # backgrounds, icons, ui 등
                filename = parts[2].split('.')[0]  # 확장자 제거
                
                if folder not in existing:
                    existing[folder] = set()
                existing[folder].add(filename)
    
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

def scan_structured_images():
    """폴더 구조를 스캔해서 이미지 목록 반환"""
    images_dir = Path("assets/images")
    if not images_dir.exists():
        print(f"❌ 이미지 폴더가 없습니다: {images_dir}")
        return {}
    
    # 지원하는 이미지 확장자
    extensions = ['.png', '.jpg', '.jpeg', '.gif', '.webp']
    structured_images = {}
    
    # 하위 폴더들 스캔
    for folder_path in images_dir.iterdir():
        if folder_path.is_dir():
            folder_name = folder_path.name
            structured_images[folder_name] = []
            
            # 해당 폴더의 이미지들 수집
            for ext in extensions:
                images = list(folder_path.glob(f'*{ext}'))
                structured_images[folder_name].extend(images)
    
    return structured_images

def generate_dart_code(all_urls_by_folder):
    """폴더별로 정리된 Dart 코드 생성"""
    print("\n🔧 image_service.dart 업데이트용 코드:")
    print("=" * 80)
    print("static const Map<String, String> _imageUrls = {")
    
    # 폴더별로 정리해서 출력
    for folder, urls in sorted(all_urls_by_folder.items()):
        print(f"  // {folder} 폴더")
        for name, url in sorted(urls.items()):
            print(f"  '{name}': '{url}',")
        print()
    
    print("};")
    
    # 폴더별 헬퍼 메서드도 생성
    print("\n// 폴더별 헬퍼 메서드 (선택사항)")
    print("=" * 50)
    for folder in sorted(all_urls_by_folder.keys()):
        method_name = f"get{folder.capitalize()}ImageUrl"
        print(f"static Future<String> {method_name}(String imageName) async {{")
        print(f"  return getImageUrl(imageName);")
        print(f"}}")
        print()

def save_structured_config(all_urls_by_folder):
    """폴더 구조를 유지한 설정 저장"""
    config_path = Path("structured_image_urls.json")
    with open(config_path, 'w', encoding='utf-8') as f:
        json.dump(all_urls_by_folder, f, indent=2, ensure_ascii=False)
    print(f"\n💾 구조화된 설정 저장됨: {config_path}")

def main():
    print("🚀 구조화된 이미지 업로드 시작")
    
    # Firebase 초기화
    bucket = init_firebase()
    
    # 기존 이미지 확인
    existing_images = get_existing_images(bucket)
    total_existing = sum(len(images) for images in existing_images.values())
    print(f"📦 기존 이미지: {total_existing}개")
    for folder, images in existing_images.items():
        print(f"   └── {folder}: {len(images)}개")
    
    # 로컬 이미지 스캔
    structured_images = scan_structured_images()
    total_local = sum(len(images) for images in structured_images.values())
    print(f"\n📁 로컬 이미지: {total_local}개")
    for folder, images in structured_images.items():
        print(f"   └── {folder}: {len(images)}개")
    
    if not structured_images:
        print("❌ 업로드할 이미지가 없습니다.")
        return
    
    all_urls_by_folder = {}
    new_uploads_by_folder = {}
    total_size = 0
    
    # 폴더별로 처리
    for folder_name, image_paths in structured_images.items():
        print(f"\n📂 {folder_name} 폴더 처리 중...")
        
        all_urls_by_folder[folder_name] = {}
        new_uploads_by_folder[folder_name] = []
        
        for image_path in image_paths:
            # 확장자 제거한 이름
            image_name = image_path.stem
            
            # 파일 크기
            file_size = image_path.stat().st_size
            total_size += file_size
            
            # 새 이미지인지 확인
            existing_in_folder = existing_images.get(folder_name, set())
            is_new = image_name not in existing_in_folder
            status = "🆕 새 이미지" if is_new else "🔄 업데이트"
            
            print(f"  {status}: {image_path.name} ({file_size / 1024 / 1024:.2f}MB)")
            
            # 업로드 (폴더 구조 유지)
            remote_path = f"images/{folder_name}/{image_path.name}"
            url = upload_image(bucket, image_path, remote_path)
            
            if url:
                all_urls_by_folder[folder_name][image_name] = url
                if is_new:
                    new_uploads_by_folder[folder_name].append(image_name)
    
    # 결과 출력
    total_new = sum(len(new_list) for new_list in new_uploads_by_folder.values())
    total_all = sum(len(url_dict) for url_dict in all_urls_by_folder.values())
    
    print(f"\n🎉 업로드 완료!")
    print(f"📊 총 용량: {total_size / 1024 / 1024:.2f}MB")
    print(f"🆕 새 이미지: {total_new}개")
    print(f"📦 전체 이미지: {total_all}개")
    
    # 폴더별 새 이미지 출력
    for folder, new_images in new_uploads_by_folder.items():
        if new_images:
            print(f"\n🆕 {folder}에 새로 추가된 이미지:")
            for name in new_images:
                print(f"  - {name}")
    
    # Dart 코드 생성
    generate_dart_code(all_urls_by_folder)
    
    # 설정 저장
    save_structured_config(all_urls_by_folder)
    
    print(f"\n📝 사용법:")
    print(f"1. 위의 코드를 lib/services/image_service.dart의 _imageUrls에 복사")
    print(f"2. 코드에서 사용: ImageService.getImageUrl('login_bg')")
    print(f"3. 또는 폴더별 메서드: getBackgroundsImageUrl('login_bg')")

if __name__ == "__main__":
    main() 