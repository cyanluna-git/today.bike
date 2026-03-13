# CLAUDE.md

Guidance for Claude Code when working with this repository.

## Project Overview

Today.Bike — 자전거 서비스 관리 플랫폼. 자전거 입고/수리/피팅/대여 워크플로우를 관리하고, 고객 포탈과 자전거 여권(QR) 기능을 제공하는 Rails 8 풀스택 애플리케이션.

## Repository Structure

- `app/models/` — 20개 도메인 모델 (Bicycle, ServiceOrder, Customer 등)
- `app/controllers/admin/` — 관리자 CRUD 컨트롤러 (17개)
- `app/controllers/portal/` — 고객 셀프서비스 포탈
- `app/views/` — ERB 템플릿 (Tailwind + Stimulus)
- `app/services/` — 비즈니스 로직 서비스 객체
- `app/jobs/` — Solid Queue 백그라운드 잡
- `db/migrate/` — SQLite 마이그레이션
- `test/` — Minitest 테스트 스위트
- `kanban-board/` — 칸반 보드 설정

## Tech Stack

- **Framework**: Ruby on Rails 8.1.2 (Hotwire: Turbo + Stimulus)
- **Database**: SQLite (primary, cache, queue, cable — 4개 인스턴스)
- **Frontend**: Tailwind CSS, Stimulus Controllers, ImportMap (ESM)
- **Auth**: Devise (관리자), Kakao OAuth (고객 포탈)
- **Background Jobs**: Solid Queue (Rails 8 기본)
- **Caching**: Solid Cache (DB-backed)
- **WebSocket**: Solid Cable
- **Asset Pipeline**: Propshaft
- **Deployment**: Kamal (Docker), Thruster (HTTP compression)

## Architecture

```
Browser → Rails 8 (Puma, port 3000)
       → SQLite (4 databases: primary, cache, queue, cable)
       → Kakao API (OAuth + 알림톡)
```

### 핵심 도메인 모델
- **Bicycle**: 개별 자전거 (road/MTB/gravel/hybrid), 프레임번호, 여권 토큰
- **Customer**: 자전거 소유자 (전화번호 기반 식별)
- **ServiceOrder**: 서비스 요청 (6가지 유형)
  - `overhaul`, `repair`, `parts`, `upgrade`, `fitting`, `frame_change`
  - 상태 워크플로우: received → diagnosis → in_progress → completed → delivered
- **ServiceProgress**: 상태 전환 감사 로그
- **BicycleSpec**: 컴포넌트 상세 사양

### 핵심 패턴
- **MVC 계층**: Model(도메인 로직) → Controller(액션) → View(ERB 렌더링)
- **Service Object**: 복잡한 비즈니스 로직은 `app/services/`에 분리
- **Stimulus Controller**: JavaScript 인터랙션은 Stimulus로 처리
- **Namespace 라우팅**: `/admin/*` (관리자), `/portal/*` (고객), `/` (공개)

## Commands

```bash
# Development
bin/rails server              # Puma on :3000
bin/rails db:migrate          # Run migrations
bin/rails db:seed             # Load seed data

# Testing
bin/rails test                # All unit/integration tests
bin/rails test:system         # System tests (Capybara + Selenium)

# Code Quality
bin/rubocop                   # RuboCop linting (omakase)
bin/rake brakeman             # Security vulnerability scan
bin/rake bundler-audit        # Gem vulnerability audit

# Deployment
kamal deploy                  # Deploy via Docker
```

## 의존성 방향 (위반 금지)

```
Controller → Service → Model
View → Helper → Model (읽기 전용)
```

- Controller에서 Model을 직접 복잡하게 조작하지 않음 — Service로 위임
- View에서 DB 쿼리 금지 — Controller/Helper에서 데이터 준비
- Model 간 순환 의존 금지

## 금지 패턴

- ❌ Controller에 비즈니스 로직 (10줄 이상의 로직은 Service로 추출)
- ❌ View에서 직접 DB 쿼리 (`@variable`만 사용)
- ❌ N+1 쿼리 (반드시 `includes`/`eager_load` 사용)
- ❌ `skip_before_action` 없이 인증 우회
- ❌ JavaScript를 inline으로 작성 (Stimulus controller로 분리)

## 필수 패턴

- ✅ 새 모델 추가 시 마이그레이션 + 테스트 + fixture 함께 생성
- ✅ 상태 변경은 ServiceProgress에 기록 (감사 추적)
- ✅ 금액 관련 필드는 정수(원) 단위로 저장
- ✅ 고객 전화번호는 한국 형식 검증 (010-XXXX-XXXX)
- ✅ Active Storage로 이미지 관리 (서비스당 최대 10장)

## CI/CD

GitHub Actions (`.github/workflows/ci.yml`):
- Brakeman 보안 스캔
- Bundler Audit
- ImportMap JS 감사
- RuboCop 린팅
- 전체 테스트 스위트
- 시스템 테스트 (스크린샷 아티팩트)
