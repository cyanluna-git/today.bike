# Today.bike — 배치 실행 계획

> 작성일: 2026-03-11
> 총 72 태스크 → 28 실행 단위 (Step)

---

## 범례

```
→       순차 (앞 태스크 완료 후 실행)
║       병렬 (동시 실행 가능)
[GATE]  게이트 — 이 지점까지 모든 태스크 완료 후 다음 진행
```

---

## Phase 0: 프로젝트 기반 (Sprint 0)

### Step 1 — Rails 프로젝트 생성
```
#706  rails new (SQLite/Tailwind/Hotwire)
  → #707  Solid Queue / Cable / Cache 설정
  → #708  GitHub 레포 + initial commit
```
> 순차. 앱이 있어야 설정하고, 설정 후 커밋.

### Step 2 — 인증 + 배포 준비 (병렬)
```
  ╔═ #709  Devise + AdminUser 모델
  ║    → #710  로그인 UI + admin 라우팅
  ║
  ╠═ #711  Dockerfile 작성  ═╗
  ║                           ╠═ (병렬)
  ╚═ #712  Kamal deploy.yml ═╝
```
> Devise와 Docker/Kamal은 서로 독립. 동시에 진행.

### Step 3 — 인프라 배포
```
#713  Hetzner VPS + Cloudflare DNS
  → #714  kamal setup + SSL
  → #715  Litestream 백업 → R2
```
> 순차. 서버 → 배포 → 백업 순서.

```
[GATE] Phase 0 완료 — Rails 앱 로컬+프로덕션 구동
```

---

## Phase 1: 핵심 운영 도구 (Sprint 1–4)

### Step 4 — 고객 모델 기반
```
#716  Customer 모델 + 마이그레이션
```
> 이후 모든 CRUD의 기반. 단독 실행.

### Step 5 — 고객 CRUD + 자전거 모델 (병렬)
```
  ╔═ #717  Admin::CustomersController CRUD + 뷰
  ║
  ╚═ #719  Bicycle 모델 + 마이그레이션
```
> 고객 CRUD 만드는 동안 Bicycle 모델 생성 병렬 가능 (모델만 만들고 뷰는 아직).

### Step 6 — 자전거 CRUD + 고객 검색 (병렬)
```
  ╔═ #718  고객 검색 + 페이지네이션
  ║
  ╠═ #720  Admin::BicyclesController CRUD
  ║    → #721  자전거 사진 업로드 (ActiveStorage)
  ║
  ╚═ #722  BicycleSpec 모델 + 스펙 등록 UI
       → #723  자전거 상세: 현재 스펙 요약 뷰
```
> 3개 스토리가 서로 다른 도메인. 병렬 실행.

```
[GATE] Sprint 1 완료 — 고객+자전거+스펙 관리 가능
```

### Step 7 — 서비스 오더 모델 기반
```
#724  ServiceOrder 모델 + 마이그레이션 (TB-YYYY-NNNN)
```

### Step 8 — 서비스 오더 CRUD
```
#725  Admin::ServiceOrdersController CRUD
  → #726  서비스 오더 등록 폼 (고객/자전거 선택)
  → #727  서비스 오더 상세 페이지 (탭 구조)
```

### Step 9 — 진행 상태 + 사진 (병렬)
```
  ╔═ #728  ServiceProgress 모델
  ║    → #729  칸반 보드 뷰
  ║    → #730  상태 변경 UI (Turbo Frame)
  ║
  ╚═ #731  ServicePhoto 모델 + ActiveStorage
       → #732  사진 다중 업로드 UI
       → #733  사진 갤러리 뷰
```
> 칸반 보드와 사진 관리는 서로 독립. 병렬 실행.

```
[GATE] Sprint 2 완료 — 정비 접수·진행·사진 관리 가능
```

### Step 10 — 정비 하위 모델 4종 (병렬)
```
  ╔═ #734  RepairLog 모델 + 폼
  ║
  ╠═ #735  PartsReplacement 모델 + 폼
  ║    → #736  BicycleSpec 자동 업데이트 콜백
  ║
  ╠═ #737  Upgrade 모델 + 폼
  ║    → #738  BicycleSpec 자동 업데이트 콜백
  ║
  ╚═ #739  FrameChange 모델 + 폼
       → #740  Bicycle+BicycleSpec 일괄 업데이트
```
> 4개 스토리 모두 ServiceOrder의 하위 모델. 서로 독립. **최대 병렬**.

### Step 11 — 피팅 (Step 10과 병렬 가능)
```
  ╔═ #741  FittingRecord 모델
  ║    → #742  피팅 입력 폼
  ║    → #743  피팅 히스토리 뷰
```
> 피팅은 Bicycle에 연결되지 ServiceOrder에는 독립. Step 10과 병렬 가능.

```
[GATE] Sprint 3 완료 — 모든 정비 유형 + 피팅 기록 가능
```

### Step 12 — 관리자 레이아웃
```
#744  Tailwind 사이드바 네비게이션 레이아웃
```
> 모든 admin 뷰의 공통 레이아웃. 단독 우선 실행.

### Step 13 — 대시보드 + 검색 + 임포트 (병렬)
```
  ╔═ #745  대시보드 메인 (입고현황, 통계)
  ║
  ╠═ #746  Ransack 통합 검색
  ║
  ╚═ #747  CSV 임포트 (고객+자전거)
       → #748  정비 이력 CSV 임포트 + 리포트
```
> 3개 모두 기존 모델을 읽기만 함. 병렬 가능.

```
[GATE] Phase 1 완료 — 엑셀 대체 완료. 샵 운영 가능.
```

---

## Phase 2: 고객 경험 (Sprint 5–6)

### Step 14 — 카카오 로그인 셋업
```
#749  OmniAuth-Kakao 설치
  → #750  Customer 매칭 로직
  → #751  포털 레이아웃 (모바일 반응형)
```

### Step 15 — 포털 뷰 4종 (병렬)
```
  ╔═ #752  Portal::Bicycles (내 자전거 + 스펙)
  ║
  ╠═ #753  Portal::ServiceOrders (정비 타임라인)
  ║    → #754  서비스 오더 상세 (고객 뷰)
  ║    → #755  Turbo Streams 실시간 현황
  ║
  ╚═ #756  Portal::FittingRecords (내 피팅)
```
> 3개 컨트롤러가 서로 다른 모델 조회. 병렬 실행.

```
[GATE] Sprint 5 완료 — 고객이 이력 조회 + 실시간 현황 확인 가능
```

### Step 16 — 알림톡 + QR 패스포트 (병렬)
```
  ╔═ Epic 7: 카카오 알림톡
  ║  #757  KakaoAlimtalkService + Notification 모델
  ║    → #758  KakaoNotificationJob
  ║    → #759  상태 변경 → 자동 알림 트리거
  ║
  ╚═ Epic 8: 디지털 패스포트
     #760  rqrcode + QR 생성  ═╗
       → #761  인쇄용 PDF       ║ (병렬)
                                ║
     #762  패스포트 공개 페이지 ═╝
```
> Epic 7과 Epic 8은 완전히 독립. **최대 병렬**.
> E8 내에서도 #761(PDF)과 #762(공개페이지)는 #760 이후 병렬 가능.

```
[GATE] Phase 2 완료 — 투명성 체감. 알림톡 + QR 패스포트 운영.
```

---

## Phase 3: 마케팅 & 수익화 (Sprint 7–9)

### Step 17 — 블로그 모델 + CRUD
```
#763  BlogPost 모델 + Action Text
  → #764  Admin CRUD + 리치 에디터
  → #765  공개 블로그 목록 + 상세 (SEO)
```

### Step 18 — 갤러리 + 마이그레이션 (병렬)
```
  ╔═ #766  Before/After 갤러리 페이지
  ║
  ╚═ #767  네이버 크롤링 rake task
       → #768  BlogPost 자동 생성 + 리포트
```
> 갤러리는 기존 ServicePhoto 기반. 크롤링은 별도 스크립트. 병렬 가능.

```
[GATE] Sprint 7 완료 — 블로그 운영 + 네이버 콘텐츠 이전
```

### Step 19 — 파츠 샵 + 대여 (병렬)
```
  ╔═ #769  Product 모델 + Admin CRUD
  ║    → #770  공개 파츠 목록 + 카카오 문의
  ║
  ╚═ #771  Rental + RentalBooking 모델 + Admin CRUD
       → #772  공개 대여 목록 + 예약 캘린더
```
> 파츠와 대여는 완전 독립. 병렬.

### Step 20 — 결제 연동
```
#773  토스페이먼츠 결제 (상품→결제→확인)
```
> Product가 있어야 하므로 Step 19 이후.

```
[GATE] Sprint 8 완료 — 파츠 판매 + 대여 온라인화
```

### Step 21 — SEO + 랜딩 (병렬)
```
  ╔═ #774  sitemap + meta-tags + robots.txt + JSON-LD
  ║
  ╠═ #775  홈페이지 (샵 소개, 서비스, 오시는 길)
  ║
  ╚═ #776  서비스 안내 페이지
```
> 3개 모두 독립. 병렬.

### Step 22 — 최종 QA
```
#777  전체 반응형 모바일 최적화 QA
```
> 모든 페이지가 완성된 후 마지막.

```
[GATE] Phase 3 완료 — 전체 플랫폼 오픈
```

---

## 실행 요약 표

| Step | 칸반 ID | 실행 모드 | 설명 |
|------|---------|-----------|------|
| 1 | 706→707→708 | 순차 | Rails 프로젝트 생성 |
| 2 | {709→710} ║ {711 ║ 712} | **병렬 2트랙** | 인증 + Docker |
| 3 | 713→714→715 | 순차 | 인프라 배포 |
| — | **GATE: Phase 0** | | |
| 4 | 716 | 단독 | Customer 모델 |
| 5 | {717} ║ {719} | **병렬** | 고객 CRUD + 자전거 모델 |
| 6 | {718} ║ {720→721} ║ {722→723} | **병렬 3트랙** | 검색 / 자전거CRUD / 스펙 |
| — | **GATE: Sprint 1** | | |
| 7 | 724 | 단독 | ServiceOrder 모델 |
| 8 | 725→726→727 | 순차 | 서비스 오더 CRUD |
| 9 | {728→729→730} ║ {731→732→733} | **병렬 2트랙** | 칸반보드 / 사진관리 |
| — | **GATE: Sprint 2** | | |
| 10 | {734} ║ {735→736} ║ {737→738} ║ {739→740} | **병렬 4트랙** | 수리/파츠/업그레이드/기변 |
| 11 | 741→742→743 | 순차 (Step 10과 **병렬**) | 피팅 |
| — | **GATE: Sprint 3** | | |
| 12 | 744 | 단독 | 관리자 레이아웃 |
| 13 | {745} ║ {746} ║ {747→748} | **병렬 3트랙** | 대시보드/검색/임포트 |
| — | **GATE: Phase 1** | | |
| 14 | 749→750→751 | 순차 | 카카오 로그인 |
| 15 | {752} ║ {753→754→755} ║ {756} | **병렬 3트랙** | 포털 뷰 |
| — | **GATE: Sprint 5** | | |
| 16 | {757→758→759} ║ {760→(761 ║ 762)} | **병렬 2트랙** | 알림톡 / QR패스포트 |
| — | **GATE: Phase 2** | | |
| 17 | 763→764→765 | 순차 | 블로그 |
| 18 | {766} ║ {767→768} | **병렬** | 갤러리 / 네이버이전 |
| — | **GATE: Sprint 7** | | |
| 19 | {769→770} ║ {771→772} | **병렬 2트랙** | 파츠샵 / 대여 |
| 20 | 773 | 단독 | 토스페이먼츠 |
| — | **GATE: Sprint 8** | | |
| 21 | {774} ║ {775} ║ {776} | **병렬 3트랙** | SEO / 홈 / 서비스안내 |
| 22 | 777 | 단독 | 최종 QA |

---

## 병렬화 효과

| 지표 | 순차 실행 | 병렬 최적화 | 절감률 |
|------|-----------|-------------|--------|
| 실행 단위 | 72 단계 | **28 단계** | 61% 감소 |
| 최대 동시 병렬 | 1 | **4트랙** (Step 10) | — |
| 병렬 활용 Step | — | **11개** / 22개 중 | 50% |

---

## /kanban-batch-run 실행 순서

```bash
# Phase 0
/kanban-batch-run 706,707,708             # Step 1: 순차
/kanban-batch-run 709,710,711,712         # Step 2: 병렬 2트랙
/kanban-batch-run 713,714,715             # Step 3: 순차

# Phase 1 - Sprint 1
/kanban-batch-run 716                     # Step 4
/kanban-batch-run 717,719                 # Step 5: 병렬
/kanban-batch-run 718,720,721,722,723     # Step 6: 병렬 3트랙

# Phase 1 - Sprint 2
/kanban-batch-run 724                     # Step 7
/kanban-batch-run 725,726,727             # Step 8: 순차
/kanban-batch-run 728,729,730,731,732,733 # Step 9: 병렬 2트랙

# Phase 1 - Sprint 3
/kanban-batch-run 734,735,736,737,738,739,740,741,742,743  # Step 10+11: 병렬 5트랙

# Phase 1 - Sprint 4
/kanban-batch-run 744                     # Step 12
/kanban-batch-run 745,746,747,748         # Step 13: 병렬 3트랙

# Phase 2 - Sprint 5
/kanban-batch-run 749,750,751             # Step 14: 순차
/kanban-batch-run 752,753,754,755,756     # Step 15: 병렬 3트랙

# Phase 2 - Sprint 6
/kanban-batch-run 757,758,759,760,761,762 # Step 16: 병렬 2트랙

# Phase 3 - Sprint 7
/kanban-batch-run 763,764,765             # Step 17: 순차
/kanban-batch-run 766,767,768             # Step 18: 병렬

# Phase 3 - Sprint 8
/kanban-batch-run 769,770,771,772         # Step 19: 병렬 2트랙
/kanban-batch-run 773                     # Step 20

# Phase 3 - Sprint 9
/kanban-batch-run 774,775,776             # Step 21: 병렬 3트랙
/kanban-batch-run 777                     # Step 22: 최종 QA
```

---

*22번의 batch-run으로 72개 태스크 전량 실행. 병렬 최적화로 순차 대비 61% 단축.*
