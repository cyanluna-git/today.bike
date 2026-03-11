#!/usr/bin/env bash
set -euo pipefail

BASE="https://cyanlunakanban.vercel.app/api/task"
AUTH="X-Kanban-Auth: 2+pg9CUzHgjjKDXxWNpMuRpnVPTTAZ5T042F+nwLz5M="
PROJECT="today.bike"

add_task() {
  local title="$1"
  local priority="${2:-medium}"
  local tags="${3:-}"
  local desc="${4:-}"

  local payload
  payload=$(cat <<ENDJSON
{"project":"${PROJECT}","title":"${title}","priority":"${priority}","tags":"${tags}","description":"${desc}"}
ENDJSON
)

  local result
  result=$(curl -s -X POST "$BASE" \
    -H "$AUTH" \
    -H "Content-Type: application/json" \
    -d "$payload")

  local id
  id=$(echo "$result" | python3 -c "import sys,json; print(json.load(sys.stdin).get('id','?'))" 2>/dev/null || echo "?")
  echo "  #${id} ${title}"
}

echo "=== Sprint 0: 프로젝트 기반 구축 ==="
echo "--- Epic 1: 프로젝트 셋업 & 인프라 ---"

add_task "[S0][E1] Ruby 3.3 + Rails 8 설치, rails new today-bike (SQLite/Tailwind/Hotwire) 생성" "high" "sprint-0,epic-1,setup" \
  "rails new today-bike --css=tailwind --database=sqlite3. Importmap 기본 사용. Procfile.dev 생성 확인. bin/dev로 로컬 개발 서버 실행 가능 상태까지."

add_task "[S0][E1] Solid Queue / Solid Cable / Solid Cache 설정 확인 및 config 정리" "high" "sprint-0,epic-1,setup" \
  "config/queue.yml, config/cable.yml, config/cache.yml 설정 확인. SQLite 기반으로 모두 동작하는지 테스트."

add_task "[S0][E1] GitHub 레포지토리 생성 + .gitignore + initial commit" "medium" "sprint-0,epic-1,setup" \
  "GitHub에 today-bike 레포 생성. .gitignore에 tmp/, log/, storage/, db/*.sqlite3 추가. 첫 커밋 푸시."

add_task "[S0][E1] Devise gem 설치 + AdminUser 모델 생성" "high" "sprint-0,epic-1,auth" \
  "Gemfile에 devise 추가. rails generate devise:install, rails generate devise AdminUser. db:migrate. 시드에 기본 관리자 계정 추가."

add_task "[S0][E1] 관리자 로그인/로그아웃 UI + admin 네임스페이스 라우팅" "high" "sprint-0,epic-1,auth" \
  "routes.rb에 namespace :admin 설정. before_action :authenticate_admin_user! 적용. Tailwind 기반 로그인 폼 작성."

add_task "[S0][E1] Dockerfile 작성 (Rails 8 production)" "medium" "sprint-0,epic-1,deploy" \
  "멀티스테이지 빌드. assets:precompile 포함. Litestream 바이너리 포함. RAILS_SERVE_STATIC_FILES=true."

add_task "[S0][E1] Kamal config/deploy.yml 작성" "medium" "sprint-0,epic-1,deploy" \
  "service: today-bike. proxy ssl host today.bike. ghcr.io 레지스트리. SQLite 볼륨 마운트. env secret 키 정의."

add_task "[S0][E1] Hetzner VPS 프로비저닝 + Cloudflare DNS today.bike 연결" "medium" "sprint-0,epic-1,deploy" \
  "Hetzner CX22 서버 생성. SSH 키 등록. Cloudflare에 today.bike A 레코드 → VPS IP. 프록시 모드 설정."

add_task "[S0][E1] kamal setup 초기 배포 + SSL 인증서 (Traefik)" "medium" "sprint-0,epic-1,deploy" \
  "kamal setup 실행. Traefik Let's Encrypt 자동 SSL 확인. https://today.bike 접속 가능 상태까지."

add_task "[S0][E1] Litestream SQLite 백업 설정 → Cloudflare R2" "medium" "sprint-0,epic-1,deploy" \
  "litestream.yml 작성. Docker 컨테이너 내 Litestream 프로세스 구동. R2 버킷 생성 및 credentials 설정. 복원 테스트."


echo ""
echo "=== Sprint 1: 고객 & 자전거 CRUD ==="
echo "--- Epic 2: 고객 & 자전거 관리 ---"

add_task "[S1][E2] Customer 모델 + 마이그레이션 생성" "high" "sprint-1,epic-2,model" \
  "name:string phone:string email:string kakao_uid:string memo:text active:boolean. phone UNIQUE 인덱스. 모델 validations 작성."

add_task "[S1][E2] Admin::CustomersController CRUD + 뷰 (목록/등록/수정/상세)" "high" "sprint-1,epic-2,crud" \
  "7 actions 모두 구현. Tailwind 기반 폼, 테이블 뷰. 고객 상세에서 연결된 자전거 목록 표시."

add_task "[S1][E2] 고객 검색 (이름/전화번호) + 페이지네이션" "medium" "sprint-1,epic-2,search" \
  "Ransack 또는 간단한 scope 기반 검색. pagy gem으로 페이지네이션. Turbo Frame으로 검색 결과 즉시 반영."

add_task "[S1][E2] Bicycle 모델 + 마이그레이션 (belongs_to :customer)" "high" "sprint-1,epic-2,model" \
  "brand:string model:string color:string frame_size:string frame_material:string serial_number:string purchase_date:date purchase_price:integer purchase_place:string notes:text active:boolean. 모델 validations + associations."

add_task "[S1][E2] Admin::BicyclesController CRUD + 뷰" "high" "sprint-1,epic-2,crud" \
  "고객 선택 가능한 자전거 등록/수정 폼. 자전거 목록 (브랜드/모델 필터). 자전거 상세 페이지."

add_task "[S1][E2] 자전거 사진 업로드 (ActiveStorage)" "medium" "sprint-1,epic-2,storage" \
  "has_one_attached :thumbnail 설정. 이미지 리사이즈 (image_processing gem). 폼에 파일 업로드 필드 추가."

add_task "[S1][E2] BicycleSpec 모델 + 컴포넌트별 스펙 등록 UI" "medium" "sprint-1,epic-2,crud" \
  "component_type + brand + model + spec_detail. UNIQUE(bicycle_id, component_type). 자전거 상세 내 nested form으로 스펙 추가/수정."

add_task "[S1][E2] 자전거 상세 페이지: 현재 스펙 요약 뷰" "low" "sprint-1,epic-2,view" \
  "BicycleSpec 데이터를 컴포넌트 타입별 테이블로 표시. 프레임, 구동계, 휠셋, 핸들/스템, 안장 등 그룹핑."


echo ""
echo "=== Sprint 2: 정비 이력 핵심 ==="
echo "--- Epic 3: 정비 이력 시스템 (Part 1) ---"

add_task "[S2][E3] ServiceOrder 모델 + 마이그레이션 (주문번호 TB-YYYY-NNNN 자동생성)" "high" "sprint-2,epic-3,model" \
  "belongs_to :bicycle, :customer. service_type enum. status enum with default received. before_create 콜백으로 order_number 생성. total_cost = labor_cost + parts_cost 가상 속성."

add_task "[S2][E3] Admin::ServiceOrdersController CRUD" "high" "sprint-2,epic-3,crud" \
  "index: 상태별 필터 + 날짜 범위 검색. new: 고객→자전거 연쇄 선택 (Stimulus로 동적 로딩). show: 탭 구조 (진행/사진/파츠/수리)."

add_task "[S2][E3] 서비스 오더 등록 폼 (고객/자전거 선택, 작업유형, 예상완료일)" "high" "sprint-2,epic-3,form" \
  "고객 선택 → 해당 고객 자전거만 필터. service_type 라디오 선택. estimated_completion 날짜 선택. customer_request 텍스트 입력."

add_task "[S2][E3] 서비스 오더 상세 페이지 (탭: 진행/사진/파츠/수리)" "high" "sprint-2,epic-3,view" \
  "Turbo Frame 탭으로 진행상태, 사진갤러리, 파츠교체내역, 수리기록을 분리. 비용 요약 사이드바. 상태 변경 버튼."

add_task "[S2][E3] ServiceProgress 모델 + 마이그레이션" "high" "sprint-2,epic-3,model" \
  "belongs_to :service_order. step_number:integer step_name:string description:text completed:boolean completed_at:datetime visible_to_customer:boolean."

add_task "[S2][E3] 입출고 칸반 보드 뷰 (접수→진단→작업중→완료→출고)" "high" "sprint-2,epic-3,kanban" \
  "5개 컬럼 칸반 보드. 각 카드: 고객명, 자전거, 입고일, 작업유형. Turbo Frame으로 상태 이동 시 즉시 반영."

add_task "[S2][E3] 칸반 상태 변경 UI (버튼 클릭 → Turbo Frame 즉시 반영)" "medium" "sprint-2,epic-3,kanban" \
  "상태 변경 버튼 클릭 → PATCH → Turbo Frame 리프레시. 또는 드래그앤드롭 (Stimulus + SortableJS)."

add_task "[S2][E3] ServicePhoto 모델 + ActiveStorage 연동" "high" "sprint-2,epic-3,model" \
  "has_one_attached :image. photo_type enum (before/progress/after/detail). belongs_to :service_order, optional belongs_to :service_progress. visible_to_customer:boolean sort_order:integer."

add_task "[S2][E3] 정비 사진 다중 업로드 UI (단계별 연결, 타입 분류)" "medium" "sprint-2,epic-3,upload" \
  "드래그앤드롭 또는 다중 파일 선택. 업로드 시 photo_type 선택 + service_progress 연결. Stimulus 컨트롤러로 미리보기."

add_task "[S2][E3] 사진 갤러리 뷰 (서비스 오더 상세 내)" "medium" "sprint-2,epic-3,view" \
  "before/progress/after 순서로 사진 그리드. 라이트박스로 확대. 캡션 표시. 고객 공개 여부 토글."


echo ""
echo "=== Sprint 3: 정비 이력 완성 + 피팅 ==="
echo "--- Epic 3: Part 2 ---"

add_task "[S3][E3] RepairLog 모델 + 증상→진단→처치 입력 폼" "medium" "sprint-3,epic-3,crud" \
  "symptom:text cause:text work_done:text notes:text. 서비스 오더 상세 내 수리 탭에서 추가/수정."

add_task "[S3][E3] PartsReplacement 모델 + 교체 전→후 입력 폼" "medium" "sprint-3,epic-3,crud" \
  "component_type 선택. old_brand/model/spec/condition → new_brand/model/spec/price. 서비스 오더 상세 내 파츠 탭에서 추가."

add_task "[S3][E3] 파츠 교체 시 BicycleSpec 자동 업데이트 콜백" "medium" "sprint-3,epic-3,logic" \
  "PartsReplacement after_create 콜백에서 해당 bicycle의 BicycleSpec 레코드를 new 값으로 upsert."

add_task "[S3][E3] Upgrade 모델 + 업그레이드 입력 폼 (전→후 스펙, 목적)" "medium" "sprint-3,epic-3,crud" \
  "before_brand/model/spec → after_brand/model/spec. upgrade_purpose (경량화/성능향상/에어로). cost."

add_task "[S3][E3] 업그레이드 시 BicycleSpec 자동 업데이트 콜백" "low" "sprint-3,epic-3,logic" \
  "Upgrade after_create 콜백에서 BicycleSpec upsert. PartsReplacement 콜백과 공통 서비스 클래스로 추출 검토."

add_task "[S3][E3] FrameChange 모델 + 기변 입력 폼 (프레임 + 이관 파츠)" "medium" "sprint-3,epic-3,crud" \
  "old → new 프레임 정보. transferred_parts JSON (체크박스로 이관 파츠 선택). 기변 시 Bicycle 정보 업데이트."

add_task "[S3][E3] 기변 시 Bicycle + BicycleSpec 일괄 업데이트" "low" "sprint-3,epic-3,logic" \
  "FrameChange after_create → bicycle.brand/model/frame_size 업데이트. 이관 안 된 파츠의 BicycleSpec 삭제."

echo "--- Epic 4: 피팅 ---"

add_task "[S3][E4] FittingRecord 모델 + 마이그레이션" "medium" "sprint-3,epic-4,model" \
  "안장(height/setback/tilt/brand/model), 핸들(width/drop/reach/stack), 스템(length/angle/spacer), 크랭크(length), 클릿(left/right). belongs_to :bicycle, :customer."

add_task "[S3][E4] 피팅 입력 폼 (전체 수치 + 사진)" "medium" "sprint-3,epic-4,form" \
  "수치 입력 폼 (decimal 필드). has_many_attached :photos. 자전거 상세 페이지 내 피팅 탭에서 접근."

add_task "[S3][E4] 피팅 히스토리 뷰 (날짜별 변경 비교)" "low" "sprint-3,epic-4,view" \
  "최신 피팅과 이전 피팅 수치를 나란히 비교. 변경된 값 하이라이트. 날짜순 리스트."


echo ""
echo "=== Sprint 4: 관리자 대시보드 & 임포트 ==="
echo "--- Epic 5: 대시보드 ---"

add_task "[S4][E5] 관리자 레이아웃 (Tailwind 사이드바 네비게이션)" "high" "sprint-4,epic-5,layout" \
  "사이드바: 대시보드/고객/자전거/정비/피팅/블로그/파츠/대여. 상단 헤더: 현재 유저, 로그아웃. 모바일 반응형 (햄버거 메뉴)."

add_task "[S4][E5] 대시보드 메인 (입고현황 요약, 최근 정비, 통계)" "medium" "sprint-4,epic-5,dashboard" \
  "현재 입고중 자전거 수 + 상태별 분포. 최근 5건 정비 이력 리스트. 이번 달 완료/출고 건수. 전체 고객/자전거 수 통계 카드."

add_task "[S4][E5] Ransack 통합 검색 (고객/자전거/서비스오더)" "medium" "sprint-4,epic-5,search" \
  "Ransack gem 설치. 고객(이름/전화), 자전거(브랜드/모델/시리얼), 서비스오더(상태/유형/날짜) 검색 폼. Turbo Frame으로 결과 즉시 반영."

add_task "[S4][E5] CSV 임포트 서비스 (고객 + 자전거)" "medium" "sprint-4,epic-5,import" \
  "CsvImportService 클래스. CSV 파싱 → Customer + Bicycle 생성. 중복 체크 (phone 기준). 임포트 결과 리포트 (성공/실패/스킵)."

add_task "[S4][E5] 정비 이력 CSV 임포트 + 결과 리포트 UI" "medium" "sprint-4,epic-5,import" \
  "ServiceOrder + 관련 레코드 CSV 임포트. 관리자 화면에서 CSV 업로드 → 프리뷰 → 확인 → 임포트 플로우."


echo ""
echo "=== Sprint 5: 고객 포털 ==="
echo "--- Epic 6: 고객 포털 ---"

add_task "[S5][E6] OmniAuth-Kakao gem 설치 + 카카오 개발자 앱 설정" "high" "sprint-5,epic-6,auth" \
  "omniauth-kakao gem 추가. config/initializers/omniauth.rb 설정. 카카오 개발자 앱에 Redirect URI 등록."

add_task "[S5][E6] 고객 카카오 로그인 → Customer 매칭 로직" "high" "sprint-5,epic-6,auth" \
  "OmniAuth 콜백에서 kakao_uid로 Customer 조회. 매칭 안 되면 전화번호 입력 후 매칭. 세션에 customer_id 저장."

add_task "[S5][E6] 포털 레이아웃 (모바일 우선 반응형)" "high" "sprint-5,epic-6,layout" \
  "모바일 퍼스트 디자인. 하단 탭 네비 (내 자전거/정비이력/피팅/설정). Tailwind 반응형. 로고 + 로그아웃 상단 헤더."

add_task "[S5][E6] Portal::BicyclesController + 내 자전거 목록/스펙 뷰" "high" "sprint-5,epic-6,portal" \
  "current_customer.bicycles 조회. 자전거 카드 (사진/브랜드/모델). 자전거 탭 → 현재 스펙 테이블 (BicycleSpec)."

add_task "[S5][E6] Portal::ServiceOrders + 정비 이력 타임라인 뷰" "high" "sprint-5,epic-6,portal" \
  "자전거별 서비스오더 타임라인 (날짜순). 각 이력: 타입 아이콘 + 날짜 + 요약 + 비용. 클릭 → 상세 (공개 사진/진행/비용)."

add_task "[S5][E6] 서비스 오더 상세 (공개 사진/진행/비용 고객 뷰)" "medium" "sprint-5,epic-6,portal" \
  "visible_to_customer=true인 진행 단계만 표시. 공개 사진 갤러리. 비용 요약. internal_notes는 숨김."

add_task "[S5][E6] Turbo Streams 실시간 정비 현황 (관리자→고객 자동 갱신)" "high" "sprint-5,epic-6,realtime" \
  "ServiceOrder 채널 구독. 관리자가 ServiceProgress 업데이트 → broadcast_replace_to → 고객 화면 자동 갱신."

add_task "[S5][E6] Portal::FittingRecords + 내 피팅 데이터 뷰" "medium" "sprint-5,epic-6,portal" \
  "최신 피팅 데이터 카드 (주요 수치 시각화). 히스토리 리스트. 피팅 사진 갤러리."


echo ""
echo "=== Sprint 6: 알림톡 + QR 패스포트 ==="
echo "--- Epic 7: 카카오 알림톡 ---"

add_task "[S6][E7] KakaoAlimtalkService + Notification 모델" "high" "sprint-6,epic-7,service" \
  "알림톡 API HTTP 클라이언트 (Net::HTTP). Notification 모델: customer_id, service_order_id, notification_type, message, status. 템플릿: checkin_confirm/work_start/progress_update/completed/delivered."

add_task "[S6][E7] KakaoNotificationJob (Solid Queue) + 알림 템플릿" "high" "sprint-6,epic-7,job" \
  "ActiveJob으로 KakaoNotificationJob 작성. Solid Queue에서 실행. 실패 시 retry + Notification status=failed 기록."

add_task "[S6][E7] ServiceOrder 상태 변경 → 자동 알림 트리거 콜백" "medium" "sprint-6,epic-7,trigger" \
  "ServiceOrder after_update 콜백. status 변경 감지 → KakaoNotificationJob.perform_later. ServiceProgress 완료 시에도 알림. 관리자 알림 이력 조회 뷰."

echo "--- Epic 8: 디지털 패스포트 ---"

add_task "[S6][E8] rqrcode gem + QR 코드 생성 (today.bike/passport/:token)" "medium" "sprint-6,epic-8,qr" \
  "Bicycle 모델에 passport_token (SecureRandom.urlsafe_base64). QR 코드 SVG/PNG 생성 메서드. QR 이미지 다운로드 + 인쇄용 레이아웃."

add_task "[S6][E8] QR 코드 이미지 다운로드 + 인쇄용 PDF" "low" "sprint-6,epic-8,qr" \
  "QR 코드를 A4에 여러 개 배치한 인쇄용 PDF. prawn gem 또는 HTML → PDF. 스티커 라벨 사이즈 옵션."

add_task "[S6][E8] 패스포트 공개 페이지 (비로그인 정비이력/스펙/피팅 열람)" "medium" "sprint-6,epic-8,passport" \
  "Public::PassportsController. token으로 bicycle 조회. 정비 타임라인 + 현재 스펙 + 피팅 데이터. is_public인 사진 포함. 모바일 최적화."


echo ""
echo "=== Sprint 7: 블로그 ==="
echo "--- Epic 9: 블로그 & 콘텐츠 ---"

add_task "[S7][E9] BlogPost 모델 + Action Text 설치" "high" "sprint-7,epic-9,model" \
  "rails action_text:install. title:string slug:string(unique) category:string tags:string naver_original_url:string published:boolean published_at:datetime view_count:integer. has_rich_text :content. has_one_attached :thumbnail."

add_task "[S7][E9] Admin::BlogPostsController CRUD + 리치 에디터 UI" "high" "sprint-7,epic-9,crud" \
  "Action Text Trix 에디터. 카테고리 선택 (repair_story/checkin/checkout/parts_review/bike_story/riding/notice). 태그 입력. 슬러그 자동 생성. 발행/임시저장."

add_task "[S7][E9] 공개 블로그 목록 (카테고리 필터) + 상세 뷰 (SEO)" "high" "sprint-7,epic-9,view" \
  "카테고리 탭 필터. 썸네일 + 제목 + excerpt 카드 그리드. 상세 뷰: 리치 텍스트 콘텐츠 + 메타 태그 + OG 태그. 이전/다음 포스트 네비."

add_task "[S7][E9] Before/After 갤러리 페이지" "medium" "sprint-7,epic-9,gallery" \
  "is_public=true인 ServiceOrder에서 before/after 사진 추출. 그리드 레이아웃. 클릭 → 서비스 오더 상세 또는 블로그 포스트 연결."

add_task "[S7][E9] 네이버 블로그 크롤링 rake task (이미지 포함)" "medium" "sprint-7,epic-9,migration" \
  "rake today_bike:migrate_naver[start_page,end_page]. Nokogiri로 HTML 파싱. 이미지 다운로드 → ActiveStorage. naver_original_url 보존."

add_task "[S7][E9] 마이그레이션 BlogPost 생성 + 진행률 리포트" "low" "sprint-7,epic-9,migration" \
  "크롤링 결과 → BlogPost 레코드 생성. 카테고리 자동 매핑. 진행률 stdout 출력. 실패 건 로그. 총 914건 목표."


echo ""
echo "=== Sprint 8: 파츠 판매 & 대여 ==="
echo "--- Epic 10: 파츠 판매 & 대여 ---"

add_task "[S8][E10] Product 모델 + Admin CRUD + 이미지 다중 업로드" "high" "sprint-8,epic-10,crud" \
  "name brand category condition used_grade price stock description spec_detail available. has_many_attached :images. Admin 상품 등록/수정/삭제 + 이미지 정렬."

add_task "[S8][E10] 공개 파츠 목록 (카테고리/검색) + 상세 + 카카오 문의" "high" "sprint-8,epic-10,shop" \
  "카테고리 필터 (groupset/wheelset/saddle 등). 검색. 상품 카드 그리드. 상세: 이미지 슬라이더 + 스펙 + 가격 + 카카오 문의 버튼 (채널톡 링크)."

add_task "[S8][E10] Rental + RentalBooking 모델 + Admin CRUD" "medium" "sprint-8,epic-10,crud" \
  "Rental: item_type name brand spec_detail daily_price available. RentalBooking: start_date end_date status total_price. Admin 대여아이템 관리 + 예약 승인/거절."

add_task "[S8][E10] 공개 대여 목록 + 예약 캘린더 + 승인 플로우" "medium" "sprint-8,epic-10,rental" \
  "대여 아이템 목록. 날짜 선택 캘린더 (Stimulus). 예약 신청 → pending → 관리자 confirmed/cancelled. 예약 현황 캘린더 뷰."

add_task "[S8][E10] 토스페이먼츠 결제 연동 (상품→결제→확인)" "medium" "sprint-8,epic-10,payment" \
  "토스페이먼츠 SDK 연동. Order 모델 생성. 결제 플로우: 상품 선택 → 주문 생성 → 결제 위젯 → 승인 → 완료. 관리자 결제 내역 뷰."


echo ""
echo "=== Sprint 9: SEO & 랜딩 ==="
echo "--- Epic 11: SEO & 공개 페이지 ---"

add_task "[S9][E11] sitemap + meta-tags + robots.txt + JSON-LD 구조화 데이터" "medium" "sprint-9,epic-11,seo" \
  "sitemap_generator gem. meta-tags gem (title/description/OG/twitter 전 페이지). robots.txt (admin, portal 차단). JSON-LD: LocalBusiness 스키마."

add_task "[S9][E11] 홈페이지 (샵 소개, 서비스 특징, 오시는 길)" "high" "sprint-9,epic-11,landing" \
  "히어로 섹션 (키 비주얼 + 캐치프레이즈). 서비스 아이콘 카드 (분해정비/수리/피팅/업그레이드). 샵 사진. 영업 시간. 카카오맵 오시는 길. CTA 버튼."

add_task "[S9][E11] 서비스 안내 페이지 (분해정비/수리/피팅/업그레이드)" "medium" "sprint-9,epic-11,landing" \
  "각 서비스별 상세 안내. 작업 과정 사진. 예상 소요시간/비용 안내. Before/After 샘플. CTA: 카카오 문의."

add_task "[S9][E11] 전체 반응형 모바일 최적화 QA" "medium" "sprint-9,epic-11,qa" \
  "모든 페이지 모바일/태블릿/데스크톱 반응형 확인. 이미지 최적화 (WebP). Lighthouse 성능 점수 체크. 크로스 브라우저 테스트."


echo ""
echo "=== 완료 ==="
echo "총 72개 태스크 등록 완료"
