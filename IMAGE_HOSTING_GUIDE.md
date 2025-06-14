# 이미지 호스팅 가이드

앱 용량을 줄이기 위해 로컬 이미지를 Firebase Storage로 이전하는 방법을 설명합니다.

## 🎯 목표
- 앱 설치 파일 크기 약 5.5MB 감소
- 네트워크를 통한 이미지 로딩으로 변경
- 이미지 캐싱으로 성능 최적화

## 📋 준비사항

### 1. Firebase Storage 활성화
1. [Firebase Console](https://console.firebase.google.com) 접속
2. 프로젝트 선택
3. Storage > 시작하기 클릭
4. 보안 규칙 설정:
```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /images/{allPaths=**} {
      allow read: if true; // 공개 읽기 허용
      allow write: if request.auth != null; // 인증된 사용자만 쓰기
    }
  }
}
```

### 2. 서비스 계정 키 다운로드
1. Firebase Console > 프로젝트 설정 > 서비스 계정
2. "새 비공개 키 생성" 클릭
3. 다운로드한 JSON 파일을 `service-account-key.json`으로 저장

### 3. Python 환경 설정
```bash
pip install firebase-admin
```

## 🚀 이미지 업로드 과정

### 1. 업로드 스크립트 수정
`upload_images.py` 파일에서 프로젝트 ID 변경:
```python
'storageBucket': 'YOUR_PROJECT_ID.appspot.com'  # 실제 프로젝트 ID로 변경
```

### 2. 이미지 업로드 실행
```bash
cd innerfive
python upload_images.py
```

### 3. image_service.dart 업데이트
업로드 완료 후 출력되는 URL들로 `lib/services/image_service.dart`의 `_imageUrls` 맵을 업데이트합니다.

## 🔧 코드 변경 방법

### 기존 코드 (로컬 이미지)
```dart
Image.asset('assets/images/login_bg.png', fit: BoxFit.cover)
```

### 변경된 코드 (네트워크 이미지)
```dart
// 1. import 추가
import 'widgets/network_background_image.dart';

// 2. 위젯 사용
NetworkBackgroundImage(
  imageName: 'login_bg',
  child: YourContentWidget(),
)
```

## 📱 성능 최적화 기능

### 1. 이미지 캐싱
- 한 번 로드된 이미지는 메모리에 캐싱
- 앱 재시작까지 유지

### 2. 프리로딩
- 앱 시작 시 모든 이미지 URL을 백그라운드에서 미리 로드
- 사용자 경험 향상

### 3. 에러 처리
- 네트워크 오류 시 재시도 버튼 제공
- 로딩 중 스피너 표시

## 🔄 변경 대상 파일들

다음 파일들에서 `Image.asset`을 `NetworkBackgroundImage`로 변경해야 합니다:

1. `lib/login_screen.dart` ✅ (완료)
2. `lib/signup_screen.dart`
3. `lib/onboarding_flow_screen.dart`
4. `lib/forgot_password_screen.dart`
5. `lib/screens/auth_for_analysis_screen.dart`

## 📊 예상 효과

### 용량 절약
- **기존**: 앱 설치 파일에 5.5MB 이미지 포함
- **변경 후**: 네트워크에서 필요할 때만 다운로드

### 장점
✅ 앱 설치 용량 대폭 감소  
✅ 이미지 업데이트 시 앱 업데이트 불필요  
✅ CDN을 통한 빠른 이미지 로딩  
✅ 디바이스 저장공간 절약

### 단점
❌ 초기 로딩 시 네트워크 필요  
❌ 네트워크 상태에 따른 로딩 시간 변동

## 🛠️ 문제 해결

### 이미지가 로드되지 않을 때
1. Firebase Storage 규칙 확인
2. 프로젝트 ID 정확성 확인
3. 네트워크 연결 상태 확인

### 캐시 초기화가 필요할 때
```dart
ImageService.clearCache();
```

## 🔐 보안 고려사항

- Firebase Storage 규칙에서 읽기는 공개, 쓰기는 인증 필요로 설정
- 이미지 URL은 일정 시간 후 만료되도록 설정 가능
- 필요시 signed URL 사용으로 더 강화된 보안 적용 가능 