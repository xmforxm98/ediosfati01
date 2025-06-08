# Flutter Web to Vercel 배포 가이드

## 🚀 배포 준비 완료!

### 변경 사항
1. **MobileWebWrapper 추가**: 웹에서 440x956 모바일 사이즈로 제한
2. **검은색 배경**: 웹에서 모바일 화면 주변이 검은색으로 표시
3. **Vercel 설정 파일**: `vercel.json` 추가
4. **빌드 스크립트**: `build.sh` 추가

### 로컬 테스트
```bash
cd innerfive
flutter pub get
flutter build web --release
```

## Vercel 배포 방법

### 1. GitHub Repository 연결
1. 코드를 GitHub에 푸시
2. [Vercel 웹사이트](https://vercel.com) 접속
3. GitHub으로 로그인
4. "New Project" 클릭
5. innerfive 저장소 선택

### 2. Vercel 설정
- **Framework Preset**: Other
- **Build Command**: `flutter build web --release`
- **Output Directory**: `build/web`
- **Install Command**: `flutter pub get`

### 3. 환경 변수 설정 (필요한 경우)
Vercel 대시보드에서 Environment Variables에 Firebase 설정 추가:
- `FIREBASE_API_KEY`
- `FIREBASE_PROJECT_ID`
- 기타 Firebase 설정값들

### 4. 배포
- "Deploy" 클릭하면 자동으로 빌드 및 배포
- 몇 분 후 라이브 URL 제공

## 🎨 모바일 웹 뷰
- 웹에서 접속하면 가운데에 440x956 크기의 모바일 화면
- 주변은 검은색 배경
- 모바일에서 접속하면 일반적인 반응형 레이아웃

## 🔧 추가 설정 (선택사항)

### Custom Domain
Vercel에서 도메인 연결 가능

### Firebase 웹 설정
`web/index.html`에서 Firebase 설정 확인 필요할 수 있음

### Performance 최적화
- `flutter build web --release --csp` (CSP 활성화)
- `flutter build web --release --pwa-strategy=offline-first` (PWA 설정)

## 🎯 테스트 완료!
빌드가 성공적으로 완료되었습니다. 이제 Vercel에 배포할 수 있습니다! 