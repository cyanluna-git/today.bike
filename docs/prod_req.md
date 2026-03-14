# Today.bike — 프로덕트 요구사항 문서 (PRD)

> 버전: 2.0
> 작성일: 2026-03-11
> 상태: 확정

---

## 1. 프로젝트 개요

**Today.bike**는 자전거 분해정비·고장수리 전문 샵이다.
"투명하고 집착에 가까운 정비"라는 브랜드 철학을 디지털로 구현하여,
엑셀 기반 운영을 전용 웹사이트로 전환하고 고객 신뢰를 극대화하는 것이 목표다.

### 운영 채널 현황

| 채널 | 계정 | 상태 |
|------|------|------|
| 네이버 블로그 | gs4454 | 운영 중 — 총 **1,774개** 포스트 |
| 카카오톡 채널 | 투데이바이크 (공식 인증) | ✅ 운영 중 — 알림톡 API 연동 신청 필요 |
| 인스타그램 | @today.bike (김기훈) | ✅ 운영 중 |
| 도메인 | today.bike | 구매 필요 |

### 블로그 콘텐츠 자산 (네이버)

| 카테고리 | 건수 | 비고 |
|----------|------|------|
| 출고되었어요! | 559 | 완성 정비 케이스 — 핵심 포트폴리오 |
| 정비이야기 | 355 | 기술력 증명 콘텐츠 |
| 입고되었어요! | 152 | 입출고 이력 |
| 자전거이야기 | 89 | 커뮤니티성 콘텐츠 |
| 판매완료(중고) | 128 | 파츠 판매 이력 |
| 휠셋/자전거 대여 | 25 | 대여 서비스 |
| 예약게시판 | 71 | 예약 운영 중 |
| 라이딩/일상 | 125 | 브랜드 인격 콘텐츠 |

### 인스타그램 (@today.bike)
- 정비 비포·애프터, 파츠 클로즈업 사진 중심 콘텐츠
- 웹사이트 Before/After 갤러리와 크로스포스팅 구조 설계 가능

### 기타 운영 현황
- 고객·정비·피팅 데이터: 현재 **엑셀 관리** (수년치 이력 보유)
- 휠셋·자전거 **대여 서비스** 운영 중
- 중고 파츠 **판매 서비스** 운영 중

---

## 2. 사용자 유형 & 권한

| 유형 | 설명 | 인증 방식 |
|------|------|-----------|
| **관리자** | 샵 오너. 전체 데이터 CRUD, 포스트 작성, 파츠 관리 | 이메일 + 비밀번호 (Devise) |
| **고객** | 본인 자전거 이력·현황 조회, 예약 신청 | 카카오 소셜 로그인 (OmniAuth) |
| **방문자** | 샵 소개, 블로그, 파츠 샵 열람 | 없음 (공개) |

---

## 3. 핵심 기능 요구사항

### 3-1. 고객 & 자전거 관리
- 고객 등록·수정 (이름, 연락처, 카카오 연동 여부, 메모)
- 고객별 자전거 등록 (브랜드, 모델, 컬러, 프레임 사이즈, 시리얼 넘버, 구매일·구매처, 사진)
- 고객 검색, 자전거 검색 (브랜드·모델·시리얼)

### 3-2. 정비 이력 관리 (핵심)

> 모든 정비 기록은 자전거 단위로 타임라인으로 누적된다.

| 이력 유형 | 필드 |
|-----------|------|
| **분해정비** | 입고일, 단계별 진행·사진·메모, 완료일, 비용 |
| **고장수리** | 증상, 원인 진단, 수리 내용, 교체 파츠, 비용 |
| **파츠 교체** | 교체 전·후 파츠 정보 (브랜드·모델·가격) |
| **업그레이드** | 기존 스펙 → 변경 스펙, 목적, 비용 |
| **기변 (프레임 교체)** | 기존 프레임 → 신규 프레임, 파츠 이관 목록, 비용 |
| **일반 점검** | 점검 항목, 조정 내용, 다음 점검 권장 시기 |

### 3-3. 피팅 정보 관리
- 안장 높이·전후·기울기 / 핸들바 높이·폭·리치 / 클릿 포지션 / 크랭크·스템 길이
- 피팅 히스토리 (날짜별 변경 추적) + 전·후 사진 첨부

### 3-4. 입출고 관리
- 입고 등록 → 단계별 상태 업데이트 → 출고 처리
- 상태 흐름: `접수 → 진단 → 작업중 → 파츠대기 → 완료 → 출고`
- 현재 입고 중 보드 (칸반 스타일)
- 카카오톡 자동 알림 (입고확인·작업시작·단계업데이트·완료·출고)

### 3-5. 고객 포털 (투명성의 핵심)
- 카카오 로그인 → 본인 자전거 목록 및 현재 스펙 조회
- 정비 이력 타임라인 (전체 이력 날짜순)
- 현재 진행 중인 정비 실시간 현황 (Turbo Streams)
- 피팅 데이터 조회

### 3-6. 블로그 & 콘텐츠
- 관리자 포스트 작성·편집·삭제 (리치 에디터)
- 카테고리: 정비이야기 / 입고 / 출고 / 파츠리뷰 / 자전거이야기 / 라이딩 / 공지
- 이미지 다중 업로드 (ActiveStorage)
- 네이버 블로그 마이그레이션 (핵심 914건 우선)
- SEO 최적화 (메타 태그, OG 태그, sitemap.xml)

### 3-7. 파츠 & 중고 판매
- 신품·중고 파츠 등록 (이름, 브랜드, 카테고리, 상태 등급, 가격, 재고, 이미지)
- Phase 1: 카카오톡 문의 기반 / Phase 3: 토스페이먼츠 결제 연동
- 카테고리: 구동계 / 휠셋 / 안장 / 핸들바·스템 / 페달 / 악세사리 / 소모품

### 3-8. 대여 서비스
- 휠셋·자전거 대여 아이템 등록
- 온라인 예약 캘린더 (날짜 단위)
- 대여 이력 관리

### 3-9. 차별화 기능
- **자전거 디지털 패스포트**: QR 코드 발급 → 스캔 시 해당 자전거 전체 이력 공개. 중고 거래 신뢰 도구.
- **Before/After 갤러리**: 정비 전·후 사진 자동 포트폴리오. 인스타그램 크로스포스팅.

---

## 4. 기술 사양

### 4-1. 확정 스택

| 레이어 | 기술 | 비고 |
|--------|------|------|
| **언어** | Ruby 3.3 | - |
| **프레임워크** | Ruby on Rails 8 | 풀스택 MVC |
| **프론트엔드** | Hotwire (Turbo + Stimulus) | React 없이 SPA급 UX |
| **CSS** | Tailwind CSS 4 | - |
| **데이터베이스** | SQLite 3 | Rails 8 기본. 단일 서버 운영에 최적 |
| **ORM** | ActiveRecord | Rails 내장 |
| **인증** | Devise + OmniAuth-Kakao | 관리자(이메일) + 고객(카카오) |
| **파일 저장** | ActiveStorage + Cloudflare R2 | 정비 사진 저장 |
| **실시간** | Turbo Streams + Solid Cable | 정비 현황 실시간 반영. Redis 불필요 |
| **백그라운드 잡** | Solid Queue | 카카오 알림톡 비동기 발송. Redis 불필요 |
| **캐시** | Solid Cache | Rails 8 내장. Redis 불필요 |
| **알림** | 카카오 알림톡 API | Solid Queue로 큐잉 후 발송 |
| **결제 (Phase 3)** | 토스페이먼츠 | 파츠 판매 결제 연동 |
| **검색** | Ransack gem | 고객·자전거·정비 검색·필터 |
| **관리자 UI** | 직접 구현 (admin/ 네임스페이스) | - |

> **SQLite 선택 근거**: 자전거샵 규모는 동시 접속자 수십 명 이하. SQLite의 단일 라이터 제약이 문제가 되지 않는 트래픽. 별도 DB 서버 불필요 → 운영 단순화. Litestream으로 실시간 백업.

### 4-2. Rails 8 Solid 트리오 (외부 서비스 제거)

```
기존 일반적인 Rails 스택:   Rails 8 이 프로젝트:
  Redis (캐시)          →   Solid Cache  (SQLite)
  Redis (잡 큐)         →   Solid Queue  (SQLite)
  Redis (WebSocket)     →   Solid Cable  (SQLite)

→ Redis 서버 없음. 외부 의존성 최소화.
```

### 4-3. 프로젝트 구조

```
today-bike/
├── app/
│   ├── models/
│   │   ├── customer.rb
│   │   ├── bicycle.rb
│   │   ├── bicycle_spec.rb
│   │   ├── service_order.rb
│   │   ├── service_progress.rb
│   │   ├── service_photo.rb
│   │   ├── repair_log.rb
│   │   ├── parts_replacement.rb
│   │   ├── upgrade.rb
│   │   ├── frame_change.rb
│   │   ├── fitting_record.rb
│   │   ├── blog_post.rb
│   │   ├── product.rb
│   │   ├── rental.rb
│   │   └── rental_booking.rb
│   ├── controllers/
│   │   ├── admin/            # 관리자 영역 (로그인 필요)
│   │   ├── portal/           # 고객 포털 (카카오 로그인)
│   │   └── public/           # 공개 영역 (블로그, 파츠샵)
│   ├── views/
│   ├── jobs/
│   │   └── kakao_notification_job.rb
│   └── services/
│       └── kakao_alimtalk_service.rb
├── db/
│   ├── schema.rb
│   └── migrate/
└── config/
    ├── database.yml          # SQLite 설정
    └── storage.yml           # Cloudflare R2 설정
```

---

## 5. 데이터베이스 스키마 (ActiveRecord Migrations)

> SQLite 3 기준. Rails ActiveRecord Migration 형식.

### 엔티티 관계도

```
customers (고객)
  └── bicycles (자전거)
        ├── bicycle_specs (현재 스펙 — 컴포넌트별)
        ├── service_orders (정비 주문 / 입출고)
        │     ├── service_progresses (단계별 진행)
        │     ├── service_photos     (정비 사진)
        │     ├── parts_replacements (파츠 교체)
        │     ├── repair_logs        (수리 진단)
        │     ├── upgrades           (업그레이드)
        │     └── frame_changes      (기변)
        └── fitting_records (피팅 이력)

blog_posts    (블로그)
products      (파츠 판매)
rentals       (대여 아이템)
  └── rental_bookings (대여 예약)
notifications (카카오 알림 이력)
```

### 마이그레이션 정의

```ruby
# customers — 고객
create_table :customers do |t|
  t.string  :name,          null: false
  t.string  :phone,         null: false             # 010-XXXX-XXXX, unique
  t.string  :email
  t.string  :kakao_uid                              # OmniAuth 카카오 식별자
  t.text    :memo                                   # 내부 메모 (비공개)
  t.boolean :active,        default: true
  t.timestamps
end
add_index :customers, :phone, unique: true

# bicycles — 고객 자전거
create_table :bicycles do |t|
  t.references :customer,   null: false, foreign_key: true
  t.string  :nickname                               # "내 TCR"
  t.string  :brand,         null: false             # Giant, Specialized ...
  t.string  :model,         null: false             # TCR Advanced SL
  t.string  :color
  t.string  :frame_size                             # S, M, 52cm ...
  t.string  :frame_material                         # 카본, 알루미늄, 티타늄
  t.string  :serial_number
  t.date    :purchase_date
  t.integer :purchase_price
  t.string  :purchase_place
  t.text    :notes
  t.boolean :active,        default: true
  t.timestamps
end

# bicycle_specs — 현재 스펙 스냅샷 (컴포넌트 타입별 1행)
create_table :bicycle_specs do |t|
  t.references :bicycle,    null: false, foreign_key: true
  t.string  :component_type, null: false
  # frame|fork|groupset|crankset|chainring|cassette|chain
  # |wheelset|tire|saddle|seatpost|handlebar|stem|headset|bb|pedal|brake|computer
  t.string  :brand
  t.string  :model
  t.string  :spec_detail                            # 11-28T, 172.5mm 등
  t.integer :purchase_year
  t.text    :notes
  t.timestamps
end
add_index :bicycle_specs, [:bicycle_id, :component_type], unique: true

# service_orders — 정비 주문 (입출고 단위)
create_table :service_orders do |t|
  t.references :bicycle,    null: false, foreign_key: true
  t.references :customer,   null: false, foreign_key: true
  t.string  :order_number,  null: false             # TB-2026-0001
  t.string  :service_type,  null: false
  # overhaul|repair|parts_replacement|upgrade|frame_change|fitting|inspection
  t.string  :status,        default: 'received'
  # received|diagnosing|in_progress|waiting_parts|completed|delivered
  t.datetime :received_at,  default: -> { 'CURRENT_TIMESTAMP' }
  t.date    :estimated_completion
  t.datetime :completed_at
  t.datetime :delivered_at
  t.integer :labor_cost,    default: 0
  t.integer :parts_cost,    default: 0
  t.text    :customer_request
  t.text    :internal_notes                         # 고객 비공개
  t.boolean :is_public,     default: false          # 블로그 연계 여부
  t.timestamps
end
add_index :service_orders, :order_number, unique: true

# service_progresses — 단계별 진행 (분해정비 핵심)
create_table :service_progresses do |t|
  t.references :service_order, null: false, foreign_key: true
  t.integer :step_number,   null: false
  t.string  :step_name,     null: false
  # 입고확인|전체분해|세척|베어링점검|구동계조정|브레이크조정|최종점검|완료
  t.text    :description
  t.boolean :completed,     default: false
  t.datetime :completed_at
  t.boolean :visible_to_customer, default: true
  t.timestamps
end

# service_photos — 정비 사진 (ActiveStorage 연동)
create_table :service_photos do |t|
  t.references :service_order,    null: false, foreign_key: true
  t.references :service_progress, foreign_key: true  # nullable
  t.string  :photo_type,  default: 'progress'
  # before|progress|after|detail
  t.string  :caption
  t.boolean :visible_to_customer, default: true
  t.integer :sort_order,  default: 0
  t.timestamps
  # 실제 파일: ActiveStorage has_one_attached :image
end

# repair_logs — 수리 진단 기록
create_table :repair_logs do |t|
  t.references :service_order, null: false, foreign_key: true
  t.text    :symptom,   null: false                 # 증상
  t.text    :cause                                  # 원인 진단
  t.text    :work_done, null: false                 # 수행 작업
  t.text    :notes
  t.timestamps
end

# parts_replacements — 파츠 교체 이력
create_table :parts_replacements do |t|
  t.references :service_order, null: false, foreign_key: true
  t.string  :component_type, null: false
  t.string  :old_brand;  t.string :old_model
  t.string  :old_spec;   t.string :old_condition   # 마모, 파손 등
  t.string  :new_brand,  null: false
  t.string  :new_model,  null: false
  t.string  :new_spec
  t.integer :new_part_price
  t.text    :notes
  t.timestamps
end

# upgrades — 업그레이드 기록
create_table :upgrades do |t|
  t.references :service_order, null: false, foreign_key: true
  t.string  :component_type, null: false
  t.string  :before_brand; t.string :before_model; t.string :before_spec
  t.string  :after_brand,  null: false
  t.string  :after_model,  null: false
  t.string  :after_spec
  t.string  :upgrade_purpose                        # 경량화, 성능향상, 에어로
  t.integer :cost
  t.text    :notes
  t.timestamps
end

# frame_changes — 기변 (프레임 교체)
create_table :frame_changes do |t|
  t.references :service_order, null: false, foreign_key: true
  t.string  :old_brand; t.string :old_model; t.string :old_frame_size
  t.string  :new_brand, null: false
  t.string  :new_model, null: false
  t.string  :new_frame_size
  t.text    :transferred_parts                      # JSON 직렬화
  t.text    :notes
  t.timestamps
end

# fitting_records — 피팅 데이터
create_table :fitting_records do |t|
  t.references :bicycle,  null: false, foreign_key: true
  t.references :customer, null: false, foreign_key: true
  t.date    :fitted_at,   null: false
  t.string  :fitter_name
  # 안장
  t.decimal :saddle_height,   precision: 5, scale: 1  # mm
  t.decimal :saddle_setback,  precision: 5, scale: 1  # mm
  t.decimal :saddle_tilt,     precision: 4, scale: 1  # degree
  t.string  :saddle_brand;    t.string :saddle_model
  # 핸들바
  t.integer :handlebar_width                           # mm
  t.decimal :handlebar_drop,  precision: 5, scale: 1
  t.decimal :reach,           precision: 5, scale: 1
  t.decimal :stack,           precision: 5, scale: 1
  # 스템
  t.integer :stem_length                               # mm
  t.decimal :stem_angle,      precision: 4, scale: 1
  t.integer :spacer_height                             # mm
  # 크랭크
  t.decimal :crank_length,    precision: 4, scale: 1  # 170, 172.5, 175
  # 클릿
  t.string  :cleat_left_position
  t.string  :cleat_right_position
  t.text    :notes
  t.timestamps
  # 피팅 사진: ActiveStorage has_many_attached :photos
end

# blog_posts — 블로그
create_table :blog_posts do |t|
  t.string  :title,       null: false
  t.string  :slug,        null: false               # URL slug (unique)
  t.text    :content,     null: false               # Action Text (rich text)
  t.text    :excerpt                                # 미리보기 요약
  t.string  :category,    null: false
  # repair_story|checkin|checkout|parts_review|bike_story|riding|notice
  t.string  :tags                                   # 콤마 구분 직렬화
  t.references :service_order, foreign_key: true    # nullable — 연결된 정비
  t.string  :naver_original_url                     # 마이그레이션 출처
  t.boolean :published,   default: false
  t.datetime :published_at
  t.integer :view_count,  default: 0
  t.timestamps
  # 썸네일: ActiveStorage has_one_attached :thumbnail
end
add_index :blog_posts, :slug, unique: true

# products — 파츠 & 중고 판매
create_table :products do |t|
  t.string  :name,        null: false
  t.string  :brand,       null: false
  t.string  :category,    null: false
  # groupset|wheelset|saddle|handlebar|stem|pedal|accessory|consumable
  t.string  :condition,   default: 'new'            # new|used
  t.string  :used_grade                             # A(상)|B(중)|C(하)
  t.integer :price,       null: false
  t.integer :stock,       default: 0
  t.text    :description
  t.string  :spec_detail
  t.boolean :available,   default: true
  t.timestamps
  # 상품 이미지: ActiveStorage has_many_attached :images
end

# rentals — 대여 아이템
create_table :rentals do |t|
  t.string  :item_type,   null: false               # bicycle|wheelset
  t.string  :name,        null: false
  t.string  :brand
  t.string  :spec_detail
  t.integer :daily_price, null: false
  t.boolean :available,   default: true
  t.text    :notes
  t.timestamps
end

# rental_bookings — 대여 예약
create_table :rental_bookings do |t|
  t.references :rental,   null: false, foreign_key: true
  t.references :customer, null: false, foreign_key: true
  t.date    :start_date,  null: false
  t.date    :end_date,    null: false
  t.string  :status,      default: 'pending'
  # pending|confirmed|in_use|returned|cancelled
  t.integer :total_price
  t.text    :notes
  t.timestamps
end

# notifications — 카카오 알림 이력
create_table :notifications do |t|
  t.references :customer,      foreign_key: true
  t.references :service_order, foreign_key: true
  t.string  :notification_type, null: false
  # checkin_confirm|work_start|progress_update|completed|delivered|reminder
  t.text    :message
  t.string  :status,  default: 'sent'               # sent|failed
  t.timestamps
end
```

---

## 6. 배포 사양

> Current reality note (2026-03-14):
> 아래 섹션은 초기 목표 아키텍처를 설명합니다.
> 실제 운영은 현재 `Hetzner + Kamal`이 아니라 `Oracle Cloud VM + bin/deploy + GHCR` 경로를 사용합니다.
> 현재 런북은 `docs/current_deploy_runbook.md`, 서버 정보는 `docs/oracle_server_info.md`를 기준으로 봅니다.

### 6-1. 인프라 구성

```
┌─────────────────────────────────────────────┐
│      Target state: Hetzner VPS (CX22)       │
│        월 ~6달러 / 2코어 / 4GB RAM          │
│                                             │
│  ┌─────────────────────────────────────┐   │
│  │  Docker Container (Kamal 관리)       │   │
│  │                                     │   │
│  │   Rails 8 앱                        │   │
│  │   ├── Puma (웹 서버)                │   │
│  │   ├── Solid Queue (백그라운드 잡)   │   │
│  │   ├── Solid Cable (WebSocket)       │   │
│  │   └── Solid Cache                  │   │
│  │                                     │   │
│  │   SQLite 파일 (DB)                  │   │
│  │   └── Litestream → Cloudflare R2   │   │
│  └─────────────────────────────────────┘   │
│                                             │
│  Kamal 2 (배포 오케스트레이션)              │
│  Traefik (리버스 프록시 + SSL 자동 갱신)    │
└─────────────────────────────────────────────┘

Cloudflare R2 (target state / 무료 티어)
├── 정비 사진 (ActiveStorage)
└── SQLite DB 실시간 백업 (Litestream)

today.bike 도메인 → Cloudflare DNS → Hetzner VPS
```

### 6-2. 배포 도구: Kamal 2 (target state)

Rails 8 공식 배포 도구. 목표 상태에서는 `git push` 후 명령 하나로 무중단 배포한다.

```yaml
# config/deploy.yml
service: today-bike
image: your-registry/today-bike

servers:
  web:
    - 1.2.3.4          # Hetzner VPS IP

proxy:
  ssl: true
  host: today.bike

registry:
  server: ghcr.io      # GitHub Container Registry (무료)
  username: <%= ENV["GITHUB_USER"] %>

volumes:
  - db/production.sqlite3:/rails/db/production.sqlite3
  - storage:/rails/storage

env:
  secret:
    - RAILS_MASTER_KEY
    - KAKAO_CLIENT_ID
    - KAKAO_CLIENT_SECRET
    - TOSS_SECRET_KEY
    - CLOUDFLARE_R2_ACCESS_KEY
    - CLOUDFLARE_R2_SECRET_KEY
```

```bash
# 최초 배포
kamal setup

# 이후 배포 (git push 후)
kamal deploy
```

### 6-3. SQLite 백업: Litestream

DB 파일이 변경될 때마다 Cloudflare R2로 실시간 복제.

> Current reality:
> Litestream 구성은 코드에 존재하지만, 실제 복제 동작은 production secrets가 완비되어야 활성화됩니다.

```yaml
# litestream.yml
dbs:
  - path: /rails/db/production.sqlite3
    replicas:
      - type: s3
        bucket: today-bike-backup
        path: db/production
        endpoint: https://xxx.r2.cloudflarestorage.com
        access-key-id: $CLOUDFLARE_R2_ACCESS_KEY
        secret-access-key: $CLOUDFLARE_R2_SECRET_KEY
```

### 6-4. 서비스별 비용 요약

| 서비스 | 용도 | 월 비용 |
|--------|------|---------|
| Hetzner VPS (CX22) | 목표 앱 + DB 서버 | ~$6 |
| Cloudflare R2 | 사진 저장 + DB 백업 | 무료 (10GB 이내) |
| Cloudflare DNS | 도메인 관리 + CDN | 무료 |
| GitHub Container Registry | Docker 이미지 | 무료 |
| 카카오 알림톡 | 건당 과금 (약 8~15원) | 사용량 비례 |
| 토스페이먼츠 | 결제 수수료 (Phase 3) | 건당 수수료 |
| today.bike 도메인 | 연 갱신 | 연 ~$30–50 |
| **합계 (목표 상태)** | | **~$6–10/월** |

### 6-5. Current Reality Snapshot

현재 실제 운영 상태는 아래와 같습니다.

| 항목 | 현재 운영 현실 |
|------|----------------|
| 서버 | Oracle Cloud Always Free VM |
| 배포 방식 | `bin/deploy` 수동 GHCR + SSH |
| 이미지 레지스트리 | GHCR |
| 데이터 저장 | Docker volume의 SQLite + local Active Storage |
| 미디어 저장소 | production은 아직 `:local` |
| 백업 | Litestream/R2는 준비돼 있으나 env 완결 여부에 의존 |

자세한 현재 런북:

- `docs/current_deploy_runbook.md`
- `docs/oracle_server_info.md`

---

## 7. 개발 단계 (Phases)

### Phase 1 — 운영 도구 (엑셀 대체)
> 목표: 샵 내부 업무를 웹으로 이관. 고객에게는 미공개.

- [ ] Rails 8 프로젝트 셋업 (SQLite, Tailwind, Devise, Hotwire)
- [ ] 고객·자전거 CRUD (scaffold 기반)
- [ ] 정비 이력 기록 (분해정비·수리·파츠교체·업그레이드·기변)
- [ ] 피팅 데이터 관리
- [ ] 입출고 관리 보드 (Turbo Frames로 칸반)
- [ ] 관리자 대시보드 (입고 현황, 통계)
- [ ] 엑셀 데이터 CSV 임포트 도구
- [ ] Kamal 기반 목표 배포 경로로 마이그레이션 여부 결정

### Phase 2 — 고객 경험 (신뢰 구축)
> 목표: 투명성으로 고객 충성도 향상.

- [ ] 카카오 OmniAuth 로그인 (고객 포털)
- [ ] 정비 이력 타임라인 (고객 뷰)
- [ ] 실시간 정비 현황 (Turbo Streams)
- [ ] 카카오 알림톡 자동 발송 (Solid Queue)
- [ ] 자전거 디지털 패스포트 (QR 코드 생성)
- [ ] ActiveStorage + Cloudflare R2 (정비 사진)

### Phase 3 — 마케팅 & 매출 확장
> 목표: 외부 유입 및 수익 채널 다각화.

- [ ] 블로그 (Action Text 리치 에디터)
- [ ] 네이버 콘텐츠 마이그레이션 (핵심 914건)
- [ ] Before/After 갤러리
- [ ] 파츠·중고 판매 (문의 → 토스페이먼츠 순)
- [ ] 대여 온라인 예약 캘린더
- [ ] SEO 최적화 (sitemap, meta, OG)

---

## 8. 네이버 블로그 마이그레이션 계획

| 카테고리 | 건수 | 우선순위 | 비고 |
|----------|------|----------|------|
| 출고되었어요! | 559 | ★★★ | 핵심 포트폴리오 |
| 정비이야기 | 355 | ★★★ | 기술력 증명 |
| 입고되었어요! | 152 | ★★☆ | 입출고 연계 |
| 판매완료(중고) | 128 | ★★☆ | 파츠 샵 연계 |
| 자전거이야기 | 89 | ★☆☆ | 커뮤니티 |
| 라이딩·일상 | 125 | ★☆☆ | 브랜드 콘텐츠 |
| 공지사항 | 30 | ★☆☆ | |

> 1단계: 핵심 914건 (출고+정비+입고) 우선 이전. 방법은 크롤링 임포트 스크립트 작성.

---

## 9. 미결 사항

| 항목 | 상태 |
|------|------|
| 도메인 today.bike 구매 | 미완료 |
| 카카오 알림톡 API 발신 프로필 등록 | 미완료 |
| 엑셀 데이터 컬럼 구조 확인 (CSV 임포트 설계) | 미완료 |
| 네이버 블로그 마이그레이션 스크립트 방식 결정 | 미완료 |
| Hetzner 서버 생성 및 SSH 키 등록 | 미완료 |
| GitHub Container Registry 설정 | 미완료 |

---

*버전 2.0 — 기술·배포 사양 확정. 이후 변경사항은 버전 업으로 관리.*
