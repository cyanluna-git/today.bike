# Today.bike — 스프린트 구현 계획

> 버전: 1.0
> 작성일: 2026-03-11
> 기반: prod_req.md v2.0

---

## 에픽 구조 요약

| # | Epic | Phase | Sprint |
|---|------|-------|--------|
| E1 | 프로젝트 셋업 & 인프라 | 0 | S0 |
| E2 | 고객 & 자전거 관리 | 1 | S1 |
| E3 | 정비 이력 시스템 | 1 | S2–S3 |
| E4 | 피팅 관리 | 1 | S3 |
| E5 | 관리자 대시보드 & 검색 | 1 | S4 |
| E6 | 고객 포털 | 2 | S5 |
| E7 | 카카오 알림톡 | 2 | S6 |
| E8 | 자전거 디지털 패스포트 | 2 | S6 |
| E9 | 블로그 & 콘텐츠 | 3 | S7 |
| E10 | 파츠 판매 & 대여 | 3 | S8 |
| E11 | SEO & 공개 페이지 | 3 | S9 |

---

## Sprint 0 — 프로젝트 기반 구축

### Epic 1: 프로젝트 셋업 & 인프라

**Story 1.1: Rails 8 프로젝트 초기화**
- T001: Ruby 3.3 + Rails 8 설치 및 rails new 생성 (SQLite, Tailwind, Hotwire)
- T002: Solid Queue / Solid Cable / Solid Cache 설정 확인
- T003: GitHub 레포 생성 및 initial commit

**Story 1.2: Devise 인증 기반**
- T004: Devise gem 설치 + Admin User 모델 생성
- T005: 관리자 로그인/로그아웃 UI + admin 네임스페이스 라우팅

**Story 1.3: 배포 환경 (목표: Kamal + Hetzner / 현재: Oracle + bin/deploy)**
- T006: Dockerfile 작성 (Rails 8 production)
- T007: Kamal config/deploy.yml 작성
- T008: 프로덕션 서버 프로비저닝 + Cloudflare DNS 연결
- T009: 초기 배포 경로 구성
- T010: Litestream SQLite 백업 → Cloudflare R2

> Current reality note:
> Sprint 문서는 초기 계획 기준이라 `Kamal + Hetzner`를 전제로 적혀 있습니다.
> 실제 운영은 현재 `Oracle Cloud VM + bin/deploy` 경로를 사용합니다.
> 현재 상태는 `docs/current_deploy_runbook.md`를 기준으로 봅니다.

---

## Sprint 1 — 고객 & 자전거 CRUD

### Epic 2: 고객 & 자전거 관리

**Story 2.1: 고객 관리**
- T011: Customer 모델 + 마이그레이션 생성
- T012: Admin::CustomersController CRUD + 뷰 (목록/등록/수정/상세)
- T013: 고객 검색 (이름, 전화번호) + 페이지네이션

**Story 2.2: 자전거 관리**
- T014: Bicycle 모델 + 마이그레이션 (belongs_to :customer)
- T015: Admin::BicyclesController CRUD + 뷰
- T016: 자전거 사진 업로드 (ActiveStorage has_one_attached :thumbnail)

**Story 2.3: 자전거 스펙 관리**
- T017: BicycleSpec 모델 + 마이그레이션 (컴포넌트 타입별)
- T018: 스펙 등록/수정 UI (자전거 상세 페이지 내 nested form)

---

## Sprint 2 — 정비 이력 핵심

### Epic 3: 정비 이력 시스템 (Part 1)

**Story 3.1: 서비스 오더 (입출고)**
- T019: ServiceOrder 모델 + 마이그레이션 (주문번호 자동생성 TB-YYYY-NNNN)
- T020: Admin::ServiceOrdersController CRUD
- T021: 서비스 오더 등록 폼 (고객/자전거 선택, 작업유형, 예상완료일)
- T022: 서비스 오더 상세 페이지 (탭 구조: 진행/사진/파츠/수리)

**Story 3.2: 진행 상태 칸반 보드**
- T023: ServiceProgress 모델 + 마이그레이션
- T024: 입출고 칸반 보드 뷰 (접수→진단→작업중→완료→출고)
- T025: 상태 변경 UI (Turbo Frame 즉시 반영)

**Story 3.3: 정비 사진**
- T026: ServicePhoto 모델 + ActiveStorage 연동
- T027: 사진 다중 업로드 UI (단계별 연결, before/progress/after 분류)
- T028: 사진 갤러리 뷰 (서비스 오더 상세 내)

---

## Sprint 3 — 정비 이력 완성 + 피팅

### Epic 3: 정비 이력 시스템 (Part 2)

**Story 3.4: 수리 진단 기록**
- T029: RepairLog 모델 + 증상→진단→처치 입력 폼

**Story 3.5: 파츠 교체 이력**
- T030: PartsReplacement 모델 + 교체 전→후 입력 폼
- T031: 파츠 교체 시 BicycleSpec 자동 업데이트 콜백

**Story 3.6: 업그레이드 기록**
- T032: Upgrade 모델 + 업그레이드 입력 폼 (전→후 스펙, 목적)
- T033: 업그레이드 시 BicycleSpec 자동 업데이트 콜백

**Story 3.7: 기변 (프레임 교체)**
- T034: FrameChange 모델 + 기변 입력 폼 (프레임 + 이관 파츠 선택)
- T035: 기변 시 Bicycle 정보 + BicycleSpec 일괄 업데이트

### Epic 4: 피팅 관리

**Story 4.1: 피팅 데이터**
- T036: FittingRecord 모델 + 마이그레이션
- T037: 피팅 입력 폼 (안장/핸들/스템/클릿/크랭크 전체 수치)
- T038: 피팅 히스토리 뷰 (날짜별 변경 비교) + 사진 업로드

---

## Sprint 4 — 관리자 대시보드 & 임포트

### Epic 5: 관리자 대시보드

**Story 5.1: 대시보드**
- T039: 관리자 레이아웃 (Tailwind 사이드바 네비게이션)
- T040: 대시보드 메인 (현재 입고중 요약, 최근 정비, 통계 카드)

**Story 5.2: 통합 검색**
- T041: Ransack gem 설치 + 고객/자전거/서비스오더 검색·필터

**Story 5.3: 엑셀 데이터 임포트**
- T042: CSV 임포트 서비스 클래스 (고객 + 자전거)
- T043: 정비 이력 CSV 임포트 + 임포트 결과 리포트 UI

---

## Sprint 5 — 고객 포털

### Epic 6: 고객 포털

**Story 6.1: 카카오 로그인**
- T044: OmniAuth-Kakao gem 설치 + 카카오 개발자 앱 설정
- T045: 고객 카카오 로그인 → Customer 매칭 로직 구현
- T046: 포털 레이아웃 (모바일 우선 반응형)

**Story 6.2: 내 자전거 & 정비 이력**
- T047: Portal::BicyclesController + 내 자전거 목록/스펙 뷰
- T048: Portal::ServiceOrdersController + 정비 이력 타임라인 뷰
- T049: 서비스 오더 상세 (공개 사진/진행/비용 뷰)

**Story 6.3: 실시간 정비 현황**
- T050: Turbo Streams 구독 — 관리자 단계 업데이트 → 고객 화면 자동 갱신

**Story 6.4: 피팅 조회**
- T051: Portal::FittingRecordsController + 내 피팅 데이터 뷰

---

## Sprint 6 — 카카오 알림 + QR 패스포트

### Epic 7: 카카오 알림톡

**Story 7.1: 알림톡 서비스**
- T052: KakaoAlimtalkService 클래스 (HTTP 클라이언트) + Notification 모델
- T053: KakaoNotificationJob (Solid Queue) + 알림 템플릿 정의
- T054: ServiceOrder 상태 변경 시 자동 알림 트리거 콜백

### Epic 8: 자전거 디지털 패스포트

**Story 8.1: QR 코드**
- T055: rqrcode gem + Bicycle QR 코드 생성 → today.bike/passport/:token
- T056: QR 코드 이미지 다운로드 + 인쇄용 PDF

**Story 8.2: 패스포트 공개 페이지**
- T057: Public::PassportsController + 정비이력/스펙/피팅 공개 뷰 (비로그인)

---

## Sprint 7 — 블로그

### Epic 9: 블로그 & 콘텐츠

**Story 9.1: 블로그 시스템**
- T058: BlogPost 모델 + Action Text 설치
- T059: Admin::BlogPostsController CRUD + 리치 에디터 작성 UI
- T060: 공개 블로그 목록 (카테고리 필터) + 상세 뷰 (SEO meta/OG)

**Story 9.2: Before/After 갤러리**
- T061: 갤러리 페이지 (is_public 서비스 오더 기반 before/after 그리드)

**Story 9.3: 네이버 마이그레이션**
- T062: 네이버 블로그 크롤링 rake task (이미지 포함)
- T063: BlogPost 자동 생성 + naver_original_url 보존 + 진행률 리포트

---

## Sprint 8 — 파츠 판매 & 대여

### Epic 10: 파츠 판매 & 대여

**Story 10.1: 파츠 샵**
- T064: Product 모델 + Admin CRUD + 이미지 다중 업로드
- T065: 공개 파츠 목록 (카테고리/검색) + 상세 뷰 + 카카오 문의 버튼

**Story 10.2: 대여 예약**
- T066: Rental + RentalBooking 모델 + Admin CRUD
- T067: 공개 대여 목록 + 예약 캘린더 UI + 관리자 승인 플로우

**Story 10.3: 토스페이먼츠**
- T068: 토스페이먼츠 결제 연동 (상품 → 결제 → 확인) + 관리자 결제 내역

---

## Sprint 9 — SEO & 랜딩

### Epic 11: SEO & 공개 페이지

**Story 11.1: SEO**
- T069: sitemap_generator + meta-tags gem + robots.txt + JSON-LD 구조화 데이터

**Story 11.2: 공개 랜딩 페이지**
- T070: 홈페이지 (샵 소개, 서비스 특징, 오시는 길)
- T071: 서비스 안내 페이지 (분해정비/수리/피팅/업그레이드)
- T072: 전체 반응형 모바일 최적화 QA

---

*총 11 Epics / 26 Stories / 72 Tasks*
