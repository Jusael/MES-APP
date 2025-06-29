# MES 모바일 앱 (Flutter + .NET API 연동)

Flutter 기반으로 제작된 모바일 MES 앱입니다.  
알림 수신, 전자서명, 바코드 리딩 등 생산현장 실무 기능을 반영하여, .NET API와 실시간으로 연동합니다.

---

## 기술 스택

### Backend (.NET 8 API)
- ASP.NET Core 8 (RESTful 구조)
- JWT 인증 및 권한 처리
- Firebase FCM 연동 (HTTP v1, OAuth2 인증)
- MSSQL + 저장 프로시저 기반 트랜잭션 처리
- 알람 큐 테이블 기반 재전송 구조 설계
- SQLite 연동 대응 DTO 설계

### Frontend (Flutter)
- Flutter 3.x
- Firebase 메시지 수신 처리 (onMessage, onMessageOpenedApp, getInitialMessage)
- SQLite 기반 알람 로컬 저장
- 바코드 리더기 연동 (barcode_scan2)
- 전자서명 기능 구현 (서명이미지 + SP 연동)
- Lottie 애니메이션 적용 (서명 처리 UX 개선)

---

## 주요 기능

- JWT 로그인 및 사용자 인증 처리
- 실시간 알람 수신 및 로컬 저장
- 알람 클릭 시 서명 진입 → 전자서명 처리
- 전자서명 결과 트랜잭션 → 큐 테이블 저장
- 실패한 알람에 대해 재전송 처리 가능
- 카메라 기반 바코드 스캔 및 피킹 처리
- 종료 상태 알람 클릭 시 포커싱 처리 구현

---

## 프로젝트 구조
lib/
┣ dto/ # AlarmDto, SignDto 등 데이터 객체
┣ services/ # FCM 초기화, 알람 처리 등
┣ repository/ # AlarmRepository (SQLite 저장소)
┣ screens/ # 로그인, 홈, 알람, 서명 등 UI 구성
┣ utils/ # 전역 상수, enum, 공용 함수
┗ main.dart # Firebase 초기화 및 라우팅

## 연동 API

| 기능 구분     | 경로                      | 메서드 |
|--------------|---------------------------|--------|
| 로그인        | /api/user/login           | POST   |
| 알람 수신     | /api/alarm/receive        | POST   |
| 서명 실행     | /api/sign/execute         | POST   |
| 알람 재전송   | /api/alarm/retry          | POST   |
| 서명 상세조회 | /api/sign/detail          | GET    |

---

## 개발 목적 및 회고

본 앱은 실제 MES/WMS 환경에서 필요한 기능 위주로 구성하였으며,  
.NET 기반 API를 직접 설계 및 구현하고, 이를 Flutter 앱과 연동하여 **단일 개발자가 서버/앱 전체를 통합 구현한 사례**입니다.

단순 CRUD 앱이 아닌,  
- 트랜잭션 기반 SP 처리,  
- 실시간 알림,  
- 전자서명 및 이미지 전송,  
- 실패 재처리 큐 구조 등  
실무 중심 아키텍처를 담고 있습니다.

---

## 기타

- Firebase Cloud Messaging 연동은 HTTP v1 방식으로 직접 구현하였으며,  
  OAuth2 토큰 발급부터 전송까지 자체 처리합니다.
- SQLite 저장소는 앱 내 알람 중복 방지 및 포커싱 기능 구현을 위해 활용하였습니다.


