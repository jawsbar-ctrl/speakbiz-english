# SpeakBiz (수안이네 영어공부방) - AI 비즈니스 영어 회화 & 스피킹 튜터

몰입도 높은 3단계 실전 학습 루프(패턴 드릴 ➔ AI 롤플레잉 ➔ 스마트 피드백)를 바탕으로 제작된 **비즈니스 영어 & 스피킹 특화 AI 회화 학습 PWA 웹앱**입니다.

[![Deploy with Vercel](https://vercel.com/button)](https://vercel.com/new/clone?repository-url=https://github.com/jawsbar-ctrl/speakbiz-english)

---

## 📱 웹앱(PWA) 접속 및 앱 설치 방법

이 프로젝트는 **Progressive Web App(PWA)** 규격을 완벽히 지원하여, 모바일/PC 어디서든 네이티브 앱처럼 설치하여 사용할 수 있습니다.

### 1. 웹 브라우저로 바로 접속
- Vercel 배포 URL (예: `https://speakbiz-english.vercel.app`)로 접속합니다.
- HTTPS 보안 연결이 적용되어 **마이크 권한을 첫 1회만 허용하면 다음부터 묻지 않고 영구 기억**됩니다.

### 2. 스마트폰 / 태블릿 홈 화면에 앱 설치
- **Android (Chrome/Edge)**: 사이트 접속 후 상단 **[앱 설치]** 버튼 또는 브라우저 메뉴(⋮)에서 **'앱 설치'** 클릭
- **iPhone / iPad (Safari)**: Safari 하단 중앙의 **공유 버튼(□↑)** 클릭 ➔ **'홈 화면에 추가'** 선택

### 3. PC (Windows / Mac) 앱 설치
- Chrome 또는 Edge 주소창 우측의 **'앱 설치'** 아이콘을 클릭하면 독립 창으로 실행되는 데스크톱 앱으로 설치됩니다.

---

## 🌟 핵심 기능 및 학습 루프 (3-Stage Loop)

### 1단계: 핵심 비즈니스 패턴 드릴 (Pattern Drill)
- 직장 실무 필수 패턴 문장을 원어민 음성(TTS)으로 청취하고 3회 반복 발화
- 음성 인식(STT)을 통한 실시간 발음 정확도 분석 및 피드백

### 2단계: 실전 비즈니스 AI 롤플레잉 (AI Roleplay)
- 실제 비즈니스 상황(회의, 일정 조율, Q&A, 연봉 협상 등) 1:1 시뮬레이션
- 1,470개 이상의 비즈니스/IT 전문 어휘 사전 및 단어 마우스 오버 한글 툴팁 & 유사 어휘 추천
- 영화 대본 명장면(악마는 프라다를 입는다 등) 20문장 연속 롤플레잉 지원

### 3단계: 스마트 AI 피드백 리포트 (Smart Report)
- 발화 문장의 비즈니스 격식 수준(Executive, Polite 등) 실시간 판정
- 원어민 추천 대체 표현 및 뉘앙스 비교 가이드
- 나만의 표현 보관함(북마크) 및 일자별 학습 시간 대시보드 그래프

---

## 🛠️ 기술 스택 & 배포 구성

- **프론트엔드**: HTML5, Tailwind CSS, Phosphor Icons, Web Speech API (STT & TTS)
- **AI 엔진**: Google Gemini API (gemini-2.5-flash / gemini-1.5-flash)
- **웹앱 규격**: PWA (Service Worker `sw.js`, Web App Manifest `manifest.json`)
- **호스팅 & CI/CD**: GitHub + Vercel Static Hosting (`vercel.json`)
