import firebase_admin
from firebase_admin import credentials, storage
import os
import shutil

try:
    # Firebase 초기화
    cred = credentials.Certificate('firebase-key.json')
    firebase_admin.initialize_app(cred, {
        'storageBucket': 'innerfive.firebasestorage.app'
    })

    bucket = storage.bucket()

    # 기존 login_bg.png를 login1.png ~ login4.png로 복사해서 업로드
    base_image_path = 'assets/images/backgrounds/login_bg.png'
    
    if not os.path.exists(base_image_path):
        print(f"Base image not found: {base_image_path}")
        exit(1)

    # login1.png ~ login4.png 생성 및 업로드
    for i in range(1, 5):
        # 임시 파일 생성
        temp_file = f'temp_login{i}.png'
        shutil.copy2(base_image_path, temp_file)
        
        try:
            # Firebase Storage에 업로드
            blob = bucket.blob(f'images/backgrounds/login{i}.png')
            blob.upload_from_filename(temp_file)
            
            # 공개 접근 가능하도록 설정
            blob.make_public()
            
            print(f'Successfully uploaded login{i}.png')
            print(f'URL: {blob.public_url}')
            
        except Exception as e:
            print(f'Failed to upload login{i}.png: {e}')
        finally:
            # 임시 파일 삭제
            if os.path.exists(temp_file):
                os.remove(temp_file)

    print('Upload completed!')

except Exception as e:
    print(f'에러: {e}') 