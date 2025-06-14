import firebase_admin
from firebase_admin import credentials, storage
import os

try:
    # Firebase 초기화
    cred = credentials.Certificate('firebase-key.json')
    firebase_admin.initialize_app(cred, {
        'storageBucket': 'innerfive.firebasestorage.app'
    })

    bucket = storage.bucket()

    print('Firebase Storage의 이미지 목록:')
    blobs = bucket.list_blobs(prefix='images/')
    for blob in blobs:
        print(f'- {blob.name}')
        
    print('\n특히 login 이미지들:')
    login_blobs = bucket.list_blobs(prefix='images/backgrounds/login')
    for blob in login_blobs:
        print(f'- {blob.name} (URL: https://storage.googleapis.com/{blob.bucket.name}/{blob.name})')
        
except Exception as e:
    print(f'에러: {e}') 