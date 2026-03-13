# frozen_string_literal: true
# db/seeds.rb — 모델하우스 데모 데이터
# 실제 운영 중인 자전거 정비샵처럼 보이도록 풍성한 데이터를 생성합니다.

puts "=== Seeding today.bike 모델하우스 데이터 ==="

# ─── Helper: 이미지 첨부 ───
SAMPLE_DIR = Rails.root.join("sample_images")

def attach_image(record, attachment_name, *paths)
  paths.flatten.each do |path|
    full = SAMPLE_DIR.join(path)
    next unless File.exist?(full)
    record.public_send(attachment_name).attach(
      io: File.open(full),
      filename: File.basename(full),
      content_type: "image/jpeg"
    )
  end
rescue => e
  puts "    ⚠ Image attach failed: #{e.message}"
end

# ─── Admin ───
admin = AdminUser.find_or_create_by!(email: "admin@today.bike") do |u|
  u.password = "password"
  u.password_confirmation = "password"
end
puts "  Admin: admin@today.bike / password"

# ─── Customers ───
customers_data = [
  { name: "김민수", phone: "010-1234-5678", email: "minsu.kim@example.com", memo: "단골 고객, 매주 토요일 라이딩 클럽 활동. Tarmac SL7 + Cervélo Áspero 보유." },
  { name: "이서연", phone: "010-2345-6789", email: "seoyeon.lee@example.com", memo: "트라이애슬론 선수. 2025 천안 철인3종 출전 예정." },
  { name: "박준혁", phone: "010-3456-7890", email: "junhyuk.park@example.com", memo: "출퇴근 자전거 이용. 비 오는 날도 자전거 출근하는 열정맨." },
  { name: "최유진", phone: "010-4567-8901", email: "yujin.choi@example.com", memo: "주말 그래벨 라이더. 금강 자전거길 단골." },
  { name: "정하늘", phone: "010-5678-9012", email: "haneul.jung@example.com", memo: "MTB 다운힐. 대둔산 트레일 주 2회." },
  { name: "강도윤", phone: "010-6789-0123", email: "doyun.kang@example.com", memo: "피팅 상담 후 정기 방문. Pinarello Dogma F 보유." },
  { name: "윤서현", phone: "010-7890-1234", email: "seohyun.yun@example.com", memo: "자전거 여행 동호회 '바람길' 회원. 국토종주 3회." },
  { name: "송지호", phone: "010-8901-2345", email: "jiho.song@example.com", memo: "로드 레이싱 입문 6개월. 첫 그란폰도 준비 중." },
  { name: "한지민", phone: "010-9012-3456", email: "jimin.han@example.com", memo: "여성 라이딩 크루 '페달시스터즈' 운영자." },
  { name: "오태현", phone: "010-0123-4567", email: "taehyun.oh@example.com", memo: "자전거 커뮤니티 유튜브 채널 운영. 리뷰용 자전거 정비 의뢰." },
]

customers = customers_data.map do |data|
  Customer.find_or_create_by!(phone: data[:phone]) do |c|
    c.name = data[:name]
    c.email = data[:email]
    c.memo = data[:memo]
  end
end
puts "  Customers: #{customers.size}명"

# ─── Bicycles ───
bicycles_data = [
  { customer: 0, brand: "Specialized", model_label: "Tarmac SL7 Expert", bike_type: "road", color: "Gloss Tarmac Black", year: 2024, frame_number: "WSBC608432190",
    photos: ["bikes/road/road_bike_01.jpg"] },
  { customer: 0, brand: "Cervélo", model_label: "Áspero-5", bike_type: "gravel", color: "White/Grey", year: 2023, frame_number: "CRV20230456",
    photos: ["bikes/road/road_bike_05.jpg"] },
  { customer: 1, brand: "Canyon", model_label: "Speedmax CF SLX", bike_type: "road", color: "Stealth", year: 2024, frame_number: "CYN2024TT001",
    photos: ["bikes/road/road_bike_03.jpg"] },
  { customer: 2, brand: "Trek", model_label: "FX 3 Disc", bike_type: "hybrid", color: "Lithium Grey", year: 2023, frame_number: "WTU337C18J",
    photos: ["bikes/road/road_bike_08.jpg"] },
  { customer: 3, brand: "Giant", model_label: "Revolt Advanced Pro 0", bike_type: "gravel", color: "Amber Glow", year: 2024, frame_number: "GNT2024GRV789",
    photos: ["bikes/road/road_bike_04.jpg"] },
  { customer: 4, brand: "Santa Cruz", model_label: "Nomad 6 CC", bike_type: "mtb", color: "Gloss Carbon", year: 2024, frame_number: "SC6N24CC1234",
    photos: ["bikes/mtb/mtb_03.jpg"] },
  { customer: 5, brand: "Pinarello", model_label: "Dogma F", bike_type: "road", color: "Razor Red", year: 2024, frame_number: "PIN2024DF567",
    photos: ["bikes/road/road_bike_02.jpg", "bikes/road/road_bike_06.jpg"] },
  { customer: 6, brand: "Surly", model_label: "Long Haul Trucker", bike_type: "road", color: "Pea Lime Soup", year: 2022, frame_number: "SUR22LHT890",
    photos: ["bikes/road/road_bike_09.jpg"] },
  { customer: 7, brand: "Giant", model_label: "TCR Advanced 2", bike_type: "road", color: "Cold Night", year: 2024, frame_number: "GNT2024TCR456",
    photos: ["bikes/road/road_bike_07.jpg"] },
  { customer: 8, brand: "Cannondale", model_label: "SuperSix EVO Hi-MOD", bike_type: "road", color: "Team Replica", year: 2024, frame_number: "CAN2024SSE123",
    photos: ["bikes/road/road_bike_10.jpg"] },
  { customer: 9, brand: "BMC", model_label: "Teammachine SLR01", bike_type: "road", color: "Neon Red/Black", year: 2024, frame_number: "BMC2024TM789",
    photos: ["bikes/road/road_bike_06.jpg"] },
]

bicycles = bicycles_data.map do |data|
  cust = customers[data[:customer]]
  bike = Bicycle.find_or_create_by!(frame_number: data[:frame_number]) do |b|
    b.customer = cust
    b.brand = data[:brand]
    b.model_label = data[:model_label]
    b.bike_type = data[:bike_type]
    b.color = data[:color]
    b.year = data[:year]
  end
  attach_image(bike, :photos, data[:photos]) unless bike.photos.attached?
  bike
end
puts "  Bicycles: #{bicycles.size}대 (with photos)"

# ─── Bicycle Specs ───
specs_data = {
  0 => [ # Tarmac SL7
    { component: "frame", brand: "Specialized", component_model: "Tarmac SL7 FACT 10r Carbon", spec_detail: "54cm" },
    { component: "fork", brand: "Specialized", component_model: "FACT Carbon, 12x100mm", spec_detail: "Full carbon" },
    { component: "groupset", brand: "Shimano", component_model: "Ultegra Di2 R8170", spec_detail: "12-speed electronic" },
    { component: "wheelset", brand: "Roval", component_model: "Rapide CLX", spec_detail: "Carbon, Tubeless Ready" },
    { component: "saddle", brand: "Specialized", component_model: "S-Works Power", spec_detail: "143mm" },
    { component: "handlebar", brand: "Roval", component_model: "Rapide Handlebar", spec_detail: "42cm" },
    { component: "tire", brand: "Specialized", component_model: "S-Works Turbo", spec_detail: "700x26c" },
    { component: "powermeter", brand: "Shimano", component_model: "Ultegra R8100-P", spec_detail: "Dual-sided" },
  ],
  2 => [ # Speedmax
    { component: "frame", brand: "Canyon", component_model: "Speedmax CF SLX", spec_detail: "S" },
    { component: "groupset", brand: "SRAM", component_model: "Red eTap AXS", spec_detail: "12-speed wireless" },
    { component: "wheelset", brand: "Zipp", component_model: "808 Firecrest", spec_detail: "Carbon disc" },
    { component: "saddle", brand: "Fizik", component_model: "Mistica", spec_detail: "TT saddle" },
  ],
  6 => [ # Dogma F
    { component: "frame", brand: "Pinarello", component_model: "Dogma F Torayca T1100 UD", spec_detail: "53cm" },
    { component: "fork", brand: "Pinarello", component_model: "Dogma F Fork", spec_detail: "Full carbon, tapered" },
    { component: "groupset", brand: "Shimano", component_model: "Dura-Ace Di2 R9270", spec_detail: "12-speed electronic" },
    { component: "wheelset", brand: "Princeton", component_model: "CarbonWorks MACH 5565", spec_detail: "55/65mm depth" },
    { component: "saddle", brand: "Fizik", component_model: "Antares R1 Adaptive", spec_detail: "140mm" },
    { component: "handlebar", brand: "Most", component_model: "Talon Ultra Aero", spec_detail: "42cm integrated" },
    { component: "seatpost", brand: "Most", component_model: "Talon Ultra Aero", spec_detail: "Carbon aero" },
    { component: "tire", brand: "Continental", component_model: "GP5000 S TR", spec_detail: "700x25c" },
    { component: "powermeter", brand: "Shimano", component_model: "Dura-Ace R9200-P", spec_detail: "Dual-sided" },
  ],
}

spec_count = 0
specs_data.each do |bike_idx, specs|
  specs.each do |spec|
    BicycleSpec.find_or_create_by!(bicycle: bicycles[bike_idx], component: spec[:component]) do |s|
      s.brand = spec[:brand]
      s.component_model = spec[:component_model]
      s.spec_detail = spec[:spec_detail]
    end
    spec_count += 1
  end
end
puts "  BicycleSpecs: #{spec_count}개"

# ─── Service Orders ───
service_orders_data = [
  # 완료/출고 — showcase 포함 (갤러리에 표시됨)
  { bicycle: 0, service_type: "overhaul", status: "delivered", received_at: 45.days.ago, expected_completion: 40.days.ago.to_date,
    completed_at: 41.days.ago, delivered_at: 40.days.ago,
    diagnosis_note: "전체 분해 후 점검. 체인 마모 0.75, BB 베어링 소음, 케이블 부식 발견.",
    work_note: "전체 분해정비 완료. 체인/케이블 교체, BB 베어링 교체, 전체 세척 및 그리스업. 라이딩 복귀 준비 완료!",
    estimated_cost: 350000, final_cost: 380000, showcase: true,
    photos: { before: ["shop/shop_05.jpg"], after: ["bikes/road/road_bike_01.jpg"] } },

  { bicycle: 2, service_type: "fitting", status: "delivered", received_at: 30.days.ago, expected_completion: 28.days.ago.to_date,
    completed_at: 28.days.ago, delivered_at: 27.days.ago,
    diagnosis_note: "TT 포지션 최적화 필요. 에어로바 높이/각도 조절, 안장 위치 미세 조정.",
    work_note: "에어로바 10mm 하향, 안장 5mm 전진. 3단계 피팅 완료. 공기저항 약 8% 개선 예상.",
    estimated_cost: 200000, final_cost: 200000, showcase: true,
    photos: { before: ["fitting/fitting_02.jpg"], after: ["fitting/fitting_06.jpg"] } },

  { bicycle: 6, service_type: "upgrade", status: "delivered", received_at: 20.days.ago, expected_completion: 15.days.ago.to_date,
    completed_at: 16.days.ago, delivered_at: 15.days.ago,
    diagnosis_note: "휠셋 업그레이드 요청. 기존 Fulcrum Racing → Princeton CarbonWorks.",
    work_note: "휠셋 교체 완료. 타이어 장착, 디스크 로터 이설, 변속 미세 조정. 무게 약 400g 감소.",
    estimated_cost: 5500000, final_cost: 5500000, showcase: true,
    photos: { before: ["bikes/parts/parts_07.jpg"], after: ["bikes/road/road_bike_02.jpg"] } },

  { bicycle: 3, service_type: "repair", status: "delivered", received_at: 25.days.ago, expected_completion: 23.days.ago.to_date,
    completed_at: 23.days.ago, delivered_at: 22.days.ago,
    diagnosis_note: "후미 변속 불량. 디레일러 행어 약간 휘어짐, 케이블 텐션 불균일.",
    work_note: "디레일러 행어 교정, 케이블 교체, 변속 조정 완료. 전단 깔끔하게 들어감.",
    estimated_cost: 50000, final_cost: 45000, showcase: true,
    photos: { before: ["bikes/parts/parts_03.jpg"], after: ["bikes/parts/parts_01.jpg"] } },

  # 추가 완료 주문 — showcase
  { bicycle: 9, service_type: "overhaul", status: "delivered", received_at: 35.days.ago, expected_completion: 30.days.ago.to_date,
    completed_at: 31.days.ago, delivered_at: 30.days.ago,
    diagnosis_note: "시즌 전 전체 점검. 체인링 마모, 바 테이프 낡음, 헤드셋 유격 발견.",
    work_note: "분해정비 + 체인링 교체 + 바 테이프 교체 + 헤드셋 베어링 교체. 새 자전거처럼 부활!",
    estimated_cost: 400000, final_cost: 420000, showcase: true,
    photos: { before: ["shop/shop_06.jpg"], after: ["bikes/road/road_bike_10.jpg"] } },

  { bicycle: 10, service_type: "repair", status: "delivered", received_at: 12.days.ago, expected_completion: 10.days.ago.to_date,
    completed_at: 10.days.ago, delivered_at: 9.days.ago,
    diagnosis_note: "유압 디스크 브레이크 에어 유입. 레버 스펀지 현상, 제동력 저하.",
    work_note: "브레이크 블리딩 완료. 미네랄 오일 교체, 패드 잔량 확인 후 유지.",
    estimated_cost: 40000, final_cost: 40000, showcase: true,
    photos: { before: ["bikes/parts/parts_04.jpg"], after: ["bikes/parts/parts_05.jpg"] } },

  # 현재 진행 중
  { bicycle: 4, service_type: "overhaul", status: "in_progress", received_at: 3.days.ago, expected_completion: 5.days.from_now.to_date,
    diagnosis_note: "그래벨 라이딩 후 전체 점검 요청. 하부 프레임 오염 심함, 체인 마모 확인 필요.",
    work_note: "분해 진행 중. 세척 완료, 베어링 점검 중.",
    estimated_cost: 300000 },

  { bicycle: 5, service_type: "repair", status: "diagnosis", received_at: 1.day.ago, expected_completion: 4.days.from_now.to_date,
    diagnosis_note: "전방 서스펜션 에어 누출 의심. 리바운드 댐핑 이상.",
    estimated_cost: 150000 },

  # 방금 접수
  { bicycle: 1, service_type: "parts", status: "received", received_at: Time.current, expected_completion: 7.days.from_now.to_date,
    estimated_cost: 800000 },

  { bicycle: 8, service_type: "overhaul", status: "received", received_at: Time.current, expected_completion: 10.days.from_now.to_date,
    estimated_cost: 250000 },
]

# Temporarily disable notification callbacks for seeding
ServiceOrder.skip_callback(:update, :after, :create_status_notification) rescue nil

orders = service_orders_data.map do |data|
  bike = bicycles[data[:bicycle]]
  ServiceOrder.find_or_create_by!(bicycle: bike, service_type: data[:service_type], received_at: data[:received_at]) do |o|
    o.status = data[:status]
    o.expected_completion = data[:expected_completion]
    o.completed_at = data[:completed_at]
    o.delivered_at = data[:delivered_at]
    o.diagnosis_note = data[:diagnosis_note]
    o.work_note = data[:work_note]
    o.estimated_cost = data[:estimated_cost]
    o.final_cost = data[:final_cost]
    o.showcase = data[:showcase] || false
  end
end

ServiceOrder.set_callback(:update, :after, :create_status_notification) rescue nil
puts "  ServiceOrders: #{orders.size}건"

# ─── Service Photos (Before/After for Gallery) ───
photo_count = 0
service_orders_data.each_with_index do |data, idx|
  next unless data[:photos]
  order = orders[idx]
  next if order.service_photos.any?

  data[:photos].each do |type, paths|
    Array(paths).each do |path|
      full = SAMPLE_DIR.join(path)
      next unless File.exist?(full)
      sp = ServicePhoto.create!(
        service_order: order,
        photo_type: type.to_s,
        caption: type == :before ? "정비 전 상태" : "정비 완료 후",
        taken_at: type == :before ? order.received_at : order.completed_at
      )
      sp.image.attach(io: File.open(full), filename: File.basename(full), content_type: "image/jpeg")
      photo_count += 1
    end
  end
end
puts "  ServicePhotos: #{photo_count}장 (Gallery before/after)"

# ─── Service Progresses ───
[
  { order: 0, transitions: [["received", "diagnosis", 45.days.ago], ["diagnosis", "in_progress", 44.days.ago], ["in_progress", "completed", 41.days.ago], ["completed", "delivered", 40.days.ago]] },
  { order: 1, transitions: [["received", "diagnosis", 30.days.ago], ["diagnosis", "in_progress", 29.days.ago], ["in_progress", "completed", 28.days.ago], ["completed", "delivered", 27.days.ago]] },
  { order: 2, transitions: [["received", "diagnosis", 20.days.ago], ["diagnosis", "in_progress", 18.days.ago], ["in_progress", "completed", 16.days.ago], ["completed", "delivered", 15.days.ago]] },
  { order: 3, transitions: [["received", "diagnosis", 25.days.ago], ["diagnosis", "in_progress", 24.days.ago], ["in_progress", "completed", 23.days.ago], ["completed", "delivered", 22.days.ago]] },
  { order: 4, transitions: [["received", "diagnosis", 35.days.ago], ["diagnosis", "in_progress", 33.days.ago], ["in_progress", "completed", 31.days.ago], ["completed", "delivered", 30.days.ago]] },
  { order: 5, transitions: [["received", "diagnosis", 12.days.ago], ["diagnosis", "in_progress", 11.days.ago], ["in_progress", "completed", 10.days.ago], ["completed", "delivered", 9.days.ago]] },
  { order: 6, transitions: [["received", "diagnosis", 3.days.ago], ["diagnosis", "in_progress", 2.days.ago]] },
  { order: 7, transitions: [["received", "diagnosis", 1.day.ago]] },
].each do |data|
  data[:transitions].each do |from, to, at|
    ServiceProgress.find_or_create_by!(service_order: orders[data[:order]], from_status: from, to_status: to) do |sp|
      sp.changed_at = at
    end
  end
end
puts "  ServiceProgresses: created"

# ─── Repair Logs ───
repair_logs_data = [
  { order: 0, repair_category: "chain", symptom: "체인 늘어남, 0.75 마모", diagnosis: "체인 체커 0.75 이상, 카세트 마모는 경미", treatment: "체인 교체 (Shimano CN-M8100), 카세트는 유지", labor_minutes: 20 },
  { order: 0, repair_category: "bearing", symptom: "BB에서 이음 소음", diagnosis: "BB 베어링 녹 및 마모", treatment: "BB 베어링 교체 (Shimano SM-BB92)", labor_minutes: 45 },
  { order: 0, repair_category: "cable", symptom: "브레이크/변속 케이블 부식", diagnosis: "외부 피복 갈라짐, 내부 케이블 녹 발생", treatment: "브레이크/변속 케이블 전체 교체", labor_minutes: 60 },
  { order: 3, repair_category: "shift", symptom: "후미 변속 부정확, 특히 저단 기어", diagnosis: "디레일러 행어 2mm 내측 휘어짐, 케이블 텐션 불균일", treatment: "행어 교정, 케이블 교체, 리밋 스크류 재조정", labor_minutes: 40 },
  { order: 5, repair_category: "brake", symptom: "유압 디스크 브레이크 스펀지 현상", diagnosis: "브레이크 라인 내 에어 유입, 미네랄 오일 열화", treatment: "브레이크 블리딩, 미네랄 오일 교체", labor_minutes: 35 },
  { order: 7, repair_category: "other", symptom: "전방 서스펜션 에어 누출, 새그 유지 안됨", diagnosis: "에어 스프링 씰 마모 의심 (분해 점검 필요)", labor_minutes: nil },
]

repair_logs_data.each do |data|
  RepairLog.find_or_create_by!(service_order: orders[data[:order]], repair_category: data[:repair_category], symptom: data[:symptom]) do |r|
    r.diagnosis = data[:diagnosis]
    r.treatment = data[:treatment]
    r.labor_minutes = data[:labor_minutes]
  end
end
puts "  RepairLogs: #{repair_logs_data.size}건"

# ─── Parts Replacements ───
parts_data = [
  { order: 0, component: "chain", old_brand: "Shimano", old_model: "CN-M8100 (마모)", new_brand: "Shimano", new_model: "CN-M8100", cost: 35000, reason: "0.75 마모, 교체 시기" },
  { order: 3, component: "brakes", old_brand: "Shimano", old_model: "케이블 세트 (부식)", new_brand: "Shimano", new_model: "OT-SP41 케이블 세트", cost: 15000, reason: "변속/브레이크 케이블 부식으로 인한 변속 불량" },
  { order: 4, component: "chain", old_brand: "Shimano", old_model: "CN-R9100 (마모)", new_brand: "Shimano", new_model: "CN-R9100", cost: 45000, reason: "체인링 마모와 함께 교체" },
]

parts_data.each do |data|
  PartsReplacement.find_or_create_by!(service_order: orders[data[:order]], component: data[:component], new_brand: data[:new_brand], new_model: data[:new_model]) do |p|
    p.old_brand = data[:old_brand]
    p.old_model = data[:old_model]
    p.cost = data[:cost]
    p.reason = data[:reason]
  end
end
puts "  PartsReplacements: #{parts_data.size}건"

# ─── Upgrades ───
upgrades_data = [
  { order: 2, component: "wheelset", before_brand: "Fulcrum", before_model: "Racing 400", after_brand: "Princeton", after_model: "CarbonWorks MACH 5565", upgrade_purpose: "performance", cost: 5200000 },
]

upgrades_data.each do |data|
  Upgrade.find_or_create_by!(service_order: orders[data[:order]], component: data[:component], after_brand: data[:after_brand]) do |u|
    u.before_brand = data[:before_brand]
    u.before_model = data[:before_model]
    u.after_model = data[:after_model]
    u.upgrade_purpose = data[:upgrade_purpose]
    u.cost = data[:cost]
  end
end
puts "  Upgrades: #{upgrades_data.size}건"

# ─── Fitting Records ───
fitting_data = [
  { bicycle: 0, saddle_height: 725.0, saddle_setback: 52.0, saddle_tilt: -1.5, saddle_brand: "Specialized", saddle_model: "S-Works Power 143mm",
    handlebar_width: 420.0, handlebar_drop: 125.0, handlebar_reach: 80.0, stem_length: 110.0, stem_angle: -6.0, stem_spacer: 15.0,
    crank_length: 172.5, notes: "안장 높이 5mm 상향 조정. 클릿 위치 내측 1mm 이동.",
    photos: ["fitting/fitting_01.jpg", "fitting/fitting_03.jpg"] },
  { bicycle: 2, saddle_height: 690.0, saddle_setback: 48.0, saddle_tilt: 0.0, saddle_brand: "Fizik", saddle_model: "Mistica",
    handlebar_width: 380.0, stem_length: 90.0, stem_angle: -17.0, stem_spacer: 0.0,
    crank_length: 170.0, notes: "TT 포지션 최적화. 에어로바 10mm 하향, 안장 5mm 전진.",
    photos: ["fitting/fitting_04.jpg", "fitting/fitting_07.jpg"] },
  { bicycle: 6, saddle_height: 715.0, saddle_setback: 50.0, saddle_tilt: -1.0, saddle_brand: "Fizik", saddle_model: "Antares R1 Adaptive 140mm",
    handlebar_width: 420.0, handlebar_drop: 128.0, handlebar_reach: 82.0, stem_length: 120.0, stem_angle: -8.0, stem_spacer: 10.0,
    crank_length: 172.5, notes: "레이스 포지션. 핸들 높이 약간 낮춤, 스페이서 5mm 제거.",
    photos: ["fitting/fitting_05.jpg", "fitting/fitting_08.jpg"] },
]

fitting_data.each do |data|
  bike = bicycles[data[:bicycle]]
  fr = FittingRecord.find_or_create_by!(bicycle: bike, saddle_height: data[:saddle_height]) do |f|
    f.saddle_setback = data[:saddle_setback]
    f.saddle_tilt = data[:saddle_tilt]
    f.saddle_brand = data[:saddle_brand]
    f.saddle_model = data[:saddle_model]
    f.handlebar_width = data[:handlebar_width]
    f.handlebar_drop = data[:handlebar_drop]
    f.handlebar_reach = data[:handlebar_reach]
    f.handlebar_stack = data[:handlebar_stack]
    f.stem_length = data[:stem_length]
    f.stem_angle = data[:stem_angle]
    f.stem_spacer = data[:stem_spacer]
    f.crank_length = data[:crank_length]
    f.notes = data[:notes]
    f.recorded_at = Time.current
  end
  attach_image(fr, :photos, data[:photos]) if data[:photos] && !fr.photos.attached?
end
puts "  FittingRecords: #{fitting_data.size}건 (with photos)"

# ─── Blog Posts (10개 — 모델하우스급 풍성한 콘텐츠) ───
blog_posts_data = [
  { title: "자전거 체인 관리의 모든 것 - 세척부터 교체 시기까지",
    category: "maintenance_tips", published: true, published_at: 50.days.ago,
    cover: "bikes/parts/parts_01.jpg",
    meta_description: "체인 수명을 늘리는 관리법과 교체 시기 판단 기준을 알려드립니다.",
    content: <<~HTML
      <h2>체인은 자전거의 심장입니다</h2>
      <p>체인은 페달의 힘을 바퀴로 전달하는 핵심 부품입니다. 관리를 소홀히 하면 변속 성능이 떨어지고, 카세트와 체인링까지 마모시켜 더 큰 비용이 발생합니다.</p>

      <h3>체인 세척 주기</h3>
      <ul>
        <li><strong>일반 라이딩</strong>: 300~500km마다 세척</li>
        <li><strong>비 오는 날 라이딩 후</strong>: 즉시 세척</li>
        <li><strong>그래벨/MTB</strong>: 매 라이딩 후 간단 세척 권장</li>
      </ul>

      <h3>체인 교체 시기 판단</h3>
      <p>체인 체커로 마모도를 측정합니다:</p>
      <ul>
        <li><strong>0.5</strong>: 교체 권장 시작점</li>
        <li><strong>0.75</strong>: 반드시 교체 (카세트 마모 전)</li>
        <li><strong>1.0 이상</strong>: 카세트도 함께 교체 필요</li>
      </ul>

      <h3>올바른 세척 방법</h3>
      <ol>
        <li>전용 체인 세척기에 디그리서를 넣고 체인을 통과시킵니다</li>
        <li>깨끗한 천으로 체인을 감싸고 페달을 역방향으로 돌려 닦아줍니다</li>
        <li>완전히 건조시킨 후 체인 오일을 한 링크씩 떨어뜨립니다</li>
        <li>여분의 오일을 천으로 닦아냅니다 — 표면에 남은 오일은 먼지만 끌어모읍니다</li>
      </ol>

      <h3>추천 체인 오일</h3>
      <p>드라이 루브는 맑은 날, 웻 루브는 비 오는 날에 적합합니다. 투데이바이크에서는 Muc-Off 드라이 루브를 기본 사용합니다. 왁스 루브(Squirt, Silca)를 선호하시는 분도 많으세요.</p>

      <p><strong>체인 관리에 대해 궁금한 점이 있다면 카카오톡으로 편하게 문의해 주세요!</strong></p>
    HTML
  },
  { title: "디스크 브레이크 패드 교체 가이드",
    category: "repair_guide", published: true, published_at: 42.days.ago,
    cover: "bikes/parts/parts_04.jpg",
    meta_description: "디스크 브레이크 패드 마모 확인법과 교체 방법을 단계별로 안내합니다.",
    content: <<~HTML
      <h2>디스크 브레이크 패드, 언제 바꿔야 할까?</h2>
      <p>패드 두께가 0.5mm 이하가 되면 교체가 필요합니다. 제동력이 떨어지고 로터를 손상시킬 수 있습니다.</p>

      <h3>마모 확인법</h3>
      <ol>
        <li>바퀴를 분리합니다</li>
        <li>캘리퍼 사이로 패드 두께를 확인합니다</li>
        <li>금속 백킹 플레이트까지 마모되었다면 즉시 교체</li>
        <li>패드 표면이 유광이거나 변색되었다면 글레이징 — 사포로 표면을 살짝 연마하거나 교체</li>
      </ol>

      <h3>패드 종류</h3>
      <ul>
        <li><strong>레진 (오가닉)</strong>: 조용하고 부드러운 제동, 마모가 빠름. 일반 라이딩에 적합</li>
        <li><strong>메탈릭 (시트드)</strong>: 강력한 제동력, 수명이 길지만 소음. 무거운 라이더나 장거리 다운힐에 추천</li>
        <li><strong>세미 메탈릭</strong>: 두 가지의 중간, 올라운드 추천</li>
      </ul>

      <h3>교체 후 주의사항</h3>
      <p>새 패드는 반드시 <strong>베드인(burn-in)</strong> 과정이 필요합니다. 중속으로 주행하며 10~20회 정도 부드럽게 제동하여 패드와 로터 표면을 맞춰줍니다. 이 과정을 건너뛰면 제동력이 불안정합니다.</p>

      <p>교체가 어려우시다면 투데이바이크로 방문해 주세요. 패드 교체 작업은 보통 15분 내에 완료됩니다.</p>
    HTML
  },
  { title: "2024 Specialized Tarmac SL7 분해정비 후기",
    category: "review", published: true, published_at: 35.days.ago,
    cover: "bikes/road/road_bike_01.jpg",
    meta_description: "1만km 주행한 Tarmac SL7 전체 분해정비 과정과 결과를 공유합니다.",
    content: <<~HTML
      <h2>1만km 주행 후 전체 분해정비</h2>
      <p>단골 고객 김민수 님의 Tarmac SL7이 1만km를 돌파하여 전체 분해정비를 진행했습니다. 주 5회 라이딩을 하시는 열정적인 라이더분인데, 평소 세척은 꾸준히 하셨지만 내부 베어링과 케이블까지는 관리가 어려우셨죠.</p>

      <h3>점검 결과</h3>
      <ul>
        <li>체인 마모: 0.75 → <strong>교체</strong></li>
        <li>BB 베어링: 소음 + 녹 → <strong>교체</strong></li>
        <li>브레이크/변속 케이블: 부식 → <strong>전체 교체</strong></li>
        <li>카세트: 경미한 마모 → <strong>유지</strong> (다음 체인 교체 시 함께 교체 권장)</li>
        <li>프레임/포크: 크랙 없음 ✓</li>
        <li>휠 텐션: 균일 ✓</li>
        <li>헤드셋 베어링: 양호 ✓</li>
        <li>디레일러 피벗: 약간 뻑뻑함 → <strong>세척 및 윤활</strong></li>
      </ul>

      <h3>작업 내용</h3>
      <p>전체 분해 후 프레임 세척, 베어링 전수 점검, 그리스업, 조립, 변속/브레이크 세팅까지 약 4시간 소요되었습니다.</p>

      <p>Di2 전자 변속기는 내부 배선 상태 확인과 펌웨어 업데이트도 함께 진행했습니다. E-Tube에서 모든 시프터 정상 동작 확인.</p>

      <h3>작업 후 고객 피드백</h3>
      <blockquote>"새 자전거 탄 느낌이에요! 특히 BB 소음이 사라지니까 라이딩이 훨씬 즐거워졌습니다." — 김민수 님</blockquote>

      <p><strong>정기적인 분해정비는 자전거의 수명을 크게 늘려줍니다. 5,000~10,000km마다 한 번씩 권장드립니다.</strong></p>
    HTML
  },
  { title: "투데이바이크 오픈 안내 - 천안 자전거 전문 정비샵",
    category: "shop_news", published: true, published_at: 90.days.ago,
    cover: "shop/shop_04.jpg",
    meta_description: "투데이바이크가 새롭게 문을 열었습니다. 충남 천안 자전거 전문 정비샵입니다.",
    content: <<~HTML
      <h2>안녕하세요, 투데이바이크입니다!</h2>
      <p>자전거를 사랑하는 라이더를 위한 전문 정비샵 투데이바이크가 충남 천안에 문을 열었습니다.</p>

      <p>오랫동안 자전거를 타며 느꼈던 "내 자전거를 믿고 맡길 수 있는 곳"을 직접 만들자는 마음으로 시작했습니다. 한 대 한 대, 정성을 다해 정비합니다.</p>

      <h3>제공 서비스</h3>
      <ul>
        <li><strong>분해정비</strong> — 전체 분해 후 세척, 점검, 그리스업, 재조립</li>
        <li><strong>수리</strong> — 변속, 브레이크, 휠, 베어링 등 전문 수리</li>
        <li><strong>피팅</strong> — 체형과 라이딩 스타일에 맞는 포지션 최적화</li>
        <li><strong>업그레이드</strong> — 파츠 교체 및 성능 향상 컨설팅</li>
        <li><strong>기변</strong> — 프레임 교체 시 파츠 이관 작업</li>
        <li><strong>렌탈</strong> — 고급 로드/MTB/그래벨 바이크 대여</li>
      </ul>

      <h3>찾아오시는 길</h3>
      <p>📍 충남 천안시 동남구 신흥1길 42 1층<br>
      📞 010-4454-5027<br>
      🕐 화~토 10:00-19:00 (일·월 휴무)</p>

      <p>방문 전 카카오톡으로 예약해 주시면 더 빠른 서비스가 가능합니다. 편하게 문의하세요!</p>
    HTML
  },
  { title: "그래벨 바이크 타이어 선택 가이드",
    category: "maintenance_tips", published: true, published_at: 28.days.ago,
    cover: "bikes/mtb/mtb_02.jpg",
    meta_description: "노면별 최적의 그래벨 타이어 추천과 공기압 세팅 가이드.",
    content: <<~HTML
      <h2>그래벨 타이어, 어떻게 골라야 할까?</h2>
      <p>그래벨 라이딩의 성패는 타이어에 달려있습니다. 노면 조건에 따라 적절한 타이어를 선택해야 편안하고 안전한 라이딩이 가능합니다.</p>

      <h3>노면별 추천</h3>
      <ul>
        <li><strong>포장도로 위주 + 가벼운 비포장</strong>: 35~38c 세미 슬릭 (Panaracer GravelKing SS, Specialized Pathfinder Pro)</li>
        <li><strong>일반 비포장 + 임도</strong>: 40~42c 올라운드 (WTB Riddler, Maxxis Rambler)</li>
        <li><strong>진흙/모래/거친 노면</strong>: 43~50c 노비 (WTB Venture, Maxxis Ravager)</li>
      </ul>

      <h3>공기압 세팅 (튜브리스 기준)</h3>
      <p>체중 70kg 라이더, 40c 타이어 기준:</p>
      <ul>
        <li>포장도로: 전 40psi / 후 42psi</li>
        <li>비포장 혼합: 전 32psi / 후 35psi</li>
        <li>거친 비포장: 전 28psi / 후 30psi</li>
      </ul>

      <h3>튜브리스 전환을 추천하는 이유</h3>
      <p>그래벨에서는 튜브리스가 거의 필수입니다:</p>
      <ol>
        <li><strong>펑크 방지</strong> — 실란트가 작은 구멍을 자동으로 메워줍니다</li>
        <li><strong>낮은 공기압 가능</strong> — 튜브 없이 림과 타이어만 있어 핀치 플랫이 없습니다</li>
        <li><strong>편안한 승차감</strong> — 낮은 공기압 덕분에 진동 흡수가 좋습니다</li>
      </ol>

      <p>튜브리스 전환 작업도 투데이바이크에서 가능합니다. 타이어 + 테이프 + 밸브 + 실란트 세트로 진행해 드립니다.</p>
    HTML
  },
  { title: "봄맞이 자전거 시즌 점검 체크리스트",
    category: "maintenance_tips", published: true, published_at: 21.days.ago,
    cover: "shop/shop_01.jpg",
    meta_description: "겨울 동안 보관했던 자전거, 봄 라이딩 전 반드시 확인해야 할 점검 항목을 정리했습니다.",
    content: <<~HTML
      <h2>겨울잠에서 깨어난 자전거, 바로 타도 될까?</h2>
      <p>겨울 동안 실내에 보관했더라도 자전거 상태는 변합니다. 타이어 공기가 빠지고, 케이블이 굳고, 오일이 마르죠. 봄 첫 라이딩 전 이 체크리스트를 확인해 보세요.</p>

      <h3>1단계: 눈으로 확인</h3>
      <ul>
        <li>타이어 사이드월 균열 확인</li>
        <li>프레임/포크 크랙 확인 (특히 카본)</li>
        <li>브레이크 패드 잔량 확인</li>
        <li>바 테이프/그립 상태</li>
      </ul>

      <h3>2단계: 만져서 확인</h3>
      <ul>
        <li>헤드셋 유격 — 앞 브레이크 잡고 앞뒤로 흔들어봄</li>
        <li>BB 유격 — 크랭크를 좌우로 흔들어봄</li>
        <li>휠 허브 유격 — 타이어를 좌우로 흔들어봄</li>
        <li>스포크 텐션 — 손으로 쥐어보며 느슨한 스포크 확인</li>
      </ul>

      <h3>3단계: 기능 확인</h3>
      <ul>
        <li>타이어 공기압 — 적정 범위로 주입</li>
        <li>브레이크 작동 — 레버 당김과 패드 접촉 확인</li>
        <li>변속 — 모든 단수 변속 확인</li>
        <li>체인 윤활 — 세척 후 오일 도포</li>
      </ul>

      <p>혼자 점검이 어렵다면 투데이바이크의 <strong>시즌 점검 서비스</strong>를 이용해 보세요. 기본 점검 + 세척 + 윤활 서비스를 합리적인 가격에 제공합니다.</p>
    HTML
  },
  { title: "바이크 피팅, 왜 중요할까? — 통증 예방부터 퍼포먼스까지",
    category: "review", published: true, published_at: 14.days.ago,
    cover: "fitting/fitting_06.jpg",
    meta_description: "바이크 피팅의 필요성과 실제 피팅 사례를 통해 어떤 변화가 있었는지 공유합니다.",
    content: <<~HTML
      <h2>피팅은 선택이 아닌 필수</h2>
      <p>"자전거를 샀는데 목이 아파요", "100km만 넘으면 무릎이 쑤셔요" — 이런 증상의 대부분은 잘못된 포지션에서 비롯됩니다.</p>

      <h3>피팅이 필요한 신호</h3>
      <ul>
        <li>🔴 무릎 앞쪽/뒤쪽 통증</li>
        <li>🔴 목/어깨 통증 (특히 장거리 시)</li>
        <li>🔴 손목 저림</li>
        <li>🔴 안장 부위 압박감/통증</li>
        <li>🔴 페달링이 부자연스러운 느낌</li>
      </ul>

      <h3>실제 피팅 사례: 강도윤 님 (Pinarello Dogma F)</h3>
      <p>강도윤 님은 Dogma F 구매 후 100km 이상 라이딩 시 목과 손목에 통증이 있었습니다.</p>
      <ul>
        <li><strong>조정 전</strong>: 스템 스페이서 15mm, 안장 높이 720mm</li>
        <li><strong>조정 후</strong>: 스페이서 10mm(-5mm), 안장 높이 715mm(-5mm), 안장 1mm 전진</li>
        <li><strong>결과</strong>: 체간 각도가 완만해지면서 목/손목 부담 감소, 200km 라이딩 후에도 통증 없음</li>
      </ul>

      <p>투데이바이크 피팅은 <strong>기본 피팅(8만원)</strong>과 <strong>정밀 피팅(15만원)</strong> 두 가지로 운영됩니다. 기존 고객 리핏팅은 5만원입니다.</p>
    HTML
  },
  { title: "라이딩 후 5분 정비 루틴 — 자전거가 오래가는 비결",
    category: "maintenance_tips", published: true, published_at: 7.days.ago,
    cover: "racing/race_09.jpg",
    meta_description: "매번 라이딩 후 5분만 투자하면 자전거 수명이 확 늘어납니다. 간단한 정비 루틴을 소개합니다.",
    content: <<~HTML
      <h2>라이딩 끝! 자전거 세워두기 전에 5분만</h2>
      <p>프로 선수들은 매 라이딩 후 자전거를 꼼꼼히 관리합니다. 우리도 5분이면 충분합니다.</p>

      <h3>1분: 체인 닦기</h3>
      <p>마른 천으로 체인을 감싸고 페달을 역방향으로 돌립니다. 표면의 먼지와 오래된 오일을 제거합니다.</p>

      <h3>1분: 타이어 확인</h3>
      <p>타이어에 유리 조각이나 날카로운 이물질이 박혀있지 않은지 확인합니다. 지금 빼지 않으면 다음 라이딩에서 펑크 확률이 높아집니다.</p>

      <h3>1분: 브레이크 & 변속 체크</h3>
      <p>브레이크 레버를 당겨보고, 변속을 한 번 전체 훑어봅니다. 이상한 소리나 느낌이 있다면 메모해두세요.</p>

      <h3>1분: 볼트 확인</h3>
      <p>핸들바, 시트포스트, 스템 볼트가 느슨해지지 않았는지 손으로 가볍게 확인합니다.</p>

      <h3>1분: 간단 세척</h3>
      <p>비가 왔거나 진흙길을 달렸다면, 물을 뿌려 큰 오염을 씻어내고 타올로 닦아줍니다. 고압수는 베어링에 물이 들어가므로 절대 사용하지 마세요!</p>

      <p><strong>이 5분 루틴을 습관으로 만들면, 정비소 방문 횟수가 절반으로 줄어듭니다.</strong></p>
    HTML
  },
  { title: "카본 프레임 관리법 — 크랙 확인부터 보관까지",
    category: "maintenance_tips", published: true, published_at: 3.days.ago,
    cover: "bikes/road/road_bike_02.jpg",
    meta_description: "카본 프레임의 올바른 관리법과 크랙 확인 방법, 안전한 보관법을 알려드립니다.",
    content: <<~HTML
      <h2>카본은 강하지만 무적은 아닙니다</h2>
      <p>카본 파이버는 무게 대비 강도가 뛰어나지만, 점 충격(낙차, 충돌)에는 취약할 수 있습니다. 올바른 관리로 카본 프레임의 수명을 극대화하세요.</p>

      <h3>크랙 확인 방법</h3>
      <ol>
        <li><strong>육안 검사</strong>: 프레임 전체를 밝은 곳에서 천천히 살펴봅니다. 특히 BB 쉘 주변, 헤드튜브, 시트스테이/체인스테이 접합부를 주의 깊게 봅니다.</li>
        <li><strong>코인 탭 테스트</strong>: 동전으로 프레임 표면을 두드립니다. 정상 부위는 "똑똑" 소리가 나고, 크랙/박리 부위는 "둔탁한" 소리가 납니다.</li>
        <li><strong>전문 검사</strong>: 낙차 후에는 반드시 전문점에서 초음파 검사를 받으세요.</li>
      </ol>

      <h3>카본 프레임 청소 시 주의사항</h3>
      <ul>
        <li>연마제가 포함된 세제는 사용하지 마세요 — UV 코팅이 벗겨집니다</li>
        <li>고압 세척기는 금물 — 베어링 씰로 물이 침투합니다</li>
        <li>부드러운 스펀지와 자전거 전용 세제를 사용하세요</li>
      </ul>

      <h3>토크 관리가 생명</h3>
      <p>카본 부품(시트포스트, 핸들바, 스템)은 반드시 <strong>토크 렌치</strong>를 사용하여 지정된 토크값으로 체결해야 합니다. 과도한 토크는 카본을 파손시킵니다.</p>

      <p>카본 프레임 점검이 필요하시면 언제든 투데이바이크를 방문해 주세요.</p>
    HTML
  },
  { title: "Pinarello Dogma F 휠셋 업그레이드 — Princeton CarbonWorks 장착기",
    category: "review", published: true, published_at: 1.day.ago,
    cover: "bikes/road/road_bike_06.jpg",
    meta_description: "Pinarello Dogma F에 Princeton CarbonWorks MACH 5565 휠셋을 장착한 업그레이드 후기.",
    content: <<~HTML
      <h2>완성차 휠 → 하이엔드 카본 휠, 어떤 차이가 날까?</h2>
      <p>강도윤 님의 Pinarello Dogma F에 Princeton CarbonWorks MACH 5565 휠셋을 장착했습니다. 기존 Fulcrum Racing 400에서의 업그레이드입니다.</p>

      <h3>스펙 비교</h3>
      <table>
        <tr><th></th><th>기존 (Fulcrum Racing 400)</th><th>변경 (Princeton MACH 5565)</th></tr>
        <tr><td>무게</td><td>1,850g</td><td>1,420g</td></tr>
        <tr><td>림 깊이</td><td>30mm</td><td>55mm(F) / 65mm(R)</td></tr>
        <tr><td>림 소재</td><td>알루미늄</td><td>Full Carbon</td></tr>
        <tr><td>허브</td><td>Fulcrum</td><td>CeramicSpeed</td></tr>
      </table>

      <h3>작업 내용</h3>
      <ol>
        <li>기존 휠셋 분리 및 타이어/디스크 로터 탈거</li>
        <li>새 휠셋에 디스크 로터 장착 (토크 렌치 40Nm)</li>
        <li>튜브리스 테이프 확인 후 Continental GP5000 S TR 장착</li>
        <li>실란트 주입 (30ml/휠)</li>
        <li>변속 미세 조정 (리어 하이/로우 리밋)</li>
        <li>브레이크 패드 간격 재조정</li>
      </ol>

      <h3>고객 시승 후기</h3>
      <blockquote>"가속이 확실히 가벼워졌어요. 특히 40km/h 이상에서 공기저항이 줄어든 느낌이 확실합니다. 자전거가 아예 다른 바이크가 된 것 같아요!" — 강도윤 님</blockquote>

      <p>휠셋 업그레이드는 자전거 성능 향상에서 가장 체감이 큰 투자입니다. 호환성 확인부터 장착까지 투데이바이크에서 전문적으로 진행해 드립니다.</p>
    HTML
  },
]

blog_posts_data.each do |data|
  post = BlogPost.find_or_create_by!(title: data[:title]) do |bp|
    bp.category = data[:category]
    bp.published = data[:published]
    bp.published_at = data[:published_at]
    bp.meta_description = data[:meta_description]
    bp.author = "투데이바이크"
  end
  post.update!(content: data[:content]) if post.content.blank?
  if data[:cover] && !post.cover_image.attached?
    attach_image(post, :cover_image, data[:cover])
  end
end
puts "  BlogPosts: #{blog_posts_data.size}개 (with cover images)"

# ─── Products (15개 — 카테고리별 풍성하게) ───
products_data = [
  # Parts
  { name: "Shimano Ultegra CN-M8100 체인 (12단)", brand: "Shimano", category: "parts", sku: "SH-CN-M8100",
    description: "시마노 울테그라급 12단 체인. HYPERGLIDE+ 기술로 빠르고 부드러운 변속. 내구성과 변속 성능이 뛰어나 데일리 라이딩부터 레이스까지 활용 가능합니다. 116링크.",
    price: 35000, stock_quantity: 15,
    images: ["bikes/parts/parts_01.jpg"] },
  { name: "Continental GP5000 S TR 700x25c", brand: "Continental", category: "parts", sku: "CO-GP5K-25",
    description: "로드 레이싱의 기준. BlackChili 컴파운드와 Vectran™ 브레이커로 낮은 구름저항, 뛰어난 그립, 우수한 펑크 방지를 동시에. 튜브리스 레디.",
    price: 65000, stock_quantity: 8,
    images: ["bikes/parts/parts_02.jpg"] },
  { name: "Shimano Dura-Ace RT-MT900 디스크 로터 160mm", brand: "Shimano", category: "parts", sku: "SH-RT-MT900",
    description: "Ice Technologies FREEZA 기술이 적용된 최상급 디스크 로터. 열 방출이 빨라 장거리 다운힐에서도 안정적인 제동력을 유지합니다.",
    price: 58000, stock_quantity: 6,
    images: ["bikes/parts/parts_03.jpg"] },
  { name: "Fizik Antares R1 Adaptive 안장 (140mm)", brand: "Fizik", category: "parts", sku: "FZ-ANT-R1",
    description: "3D 프린팅 기술의 어댑티브 패딩. 라이더의 체압에 따라 형태가 변하는 혁신적인 안장. 카본 레일, 무게 175g.",
    price: 280000, stock_quantity: 3,
    images: ["bikes/parts/parts_08.jpg"] },
  { name: "Vittoria Corsa N.EXT TLR 700x28c", brand: "Vittoria", category: "parts", sku: "VI-CORSA-28",
    description: "나일론 케이싱의 고성능 튜브리스 레디 타이어. Graphene + Silica 컴파운드. 그립과 내구성의 밸런스가 뛰어난 올라운드 타이어.",
    price: 55000, stock_quantity: 12,
    images: ["bikes/parts/parts_06.jpg"] },

  # Accessories
  { name: "Muc-Off Dry Chain Lube 120ml", brand: "Muc-Off", category: "accessories", sku: "MO-DRY-120",
    description: "맑은 날씨용 드라이 체인 루브. 먼지 부착이 적고 깨끗한 드라이브트레인 유지. 생분해성 포뮬러.",
    price: 18000, stock_quantity: 25,
    images: ["bikes/parts/parts_05.jpg"] },
  { name: "Elite Fly 물통 550ml", brand: "Elite", category: "accessories", sku: "EL-FLY-550",
    description: "단 54g의 초경량 물통. 프로 투어 팀에서 사용하는 레이스용 물통. BPA 프리, 부드러운 압착감.",
    price: 12000, stock_quantity: 30,
    images: ["shop/shop_09.jpg"] },
  { name: "Park Tool Chain Checker CC-2", brand: "Park Tool", category: "accessories", sku: "PT-CC2",
    description: "체인 마모도를 정확하게 측정하는 필수 공구. 0.5/0.75 양면 체커. 셀프 정비의 첫 걸음.",
    price: 22000, stock_quantity: 10,
    images: ["shop/shop_10.jpg"] },
  { name: "Lezyne Lite Drive 1200+ 전조등", brand: "Lezyne", category: "accessories", sku: "LZ-LD1200",
    description: "1200루멘 충전식 전조등. 5가지 밝기 모드, USB-C 충전, 방수 등급 IPX7. 야간 라이딩 필수.",
    price: 89000, stock_quantity: 7,
    images: ["shop/shop_11.jpg"] },
  { name: "Topeak Alien 3 멀티툴 (31기능)", brand: "Topeak", category: "accessories", sku: "TP-ALIEN3",
    description: "31가지 기능의 만능 멀티툴. 체인 커터, 스포크 렌치 포함. 라이딩 중 비상 정비에 필수. 무게 275g.",
    price: 45000, stock_quantity: 8,
    images: ["shop/shop_12.jpg"] },

  # Apparel
  { name: "Castelli Gabba RoS 2 저지", brand: "Castelli", category: "apparel", sku: "CA-GABBA-M",
    description: "전설적인 올웨더 저지의 2세대. Gore-Tex INFINIUM™ WINDSTOPPER®. 10~18°C에 최적. 가볍고 통기성도 확보한 프로급 저지.",
    price: 250000, sale_price: 199000, stock_quantity: 5,
    images: ["racing/race_07.jpg"] },
  { name: "Rapha Core Bib Shorts", brand: "Rapha", category: "apparel", sku: "RP-CORE-BIB",
    description: "합리적인 가격의 고품질 빕숏. 편안한 패드와 내구성 높은 원단. 입문자부터 중급 라이더까지 추천.",
    price: 120000, stock_quantity: 10,
    images: ["racing/race_04.jpg"] },

  # Nutrition
  { name: "SIS GO Energy Bar 40g x 6팩", brand: "SIS", category: "nutrition", sku: "SIS-GO-6PK",
    description: "라이딩 중 에너지 보충용 바. 소화가 잘 되는 포뮬러. 26g 탄수화물/개. 베리맛, 초콜릿맛 혼합.",
    price: 15000, stock_quantity: 40,
    images: ["shop/shop_08.jpg"] },
  { name: "Maurten Drink Mix 320 (10팩)", brand: "Maurten", category: "nutrition", sku: "MT-DM320-10",
    description: "하이드로겔 기술의 고농도 탄수화물 드링크. 80g 탄수화물/서빙. 프로 투어 선수들의 선택. 위장 부담 최소화.",
    price: 45000, stock_quantity: 15,
    images: ["shop/shop_07.jpg"] },
  { name: "SIS GO Electrolyte 500g (레몬라임)", brand: "SIS", category: "nutrition", sku: "SIS-ELEC-500",
    description: "전해질 보충용 음료 파우더. 나트륨, 칼륨, 마그네슘 균형 배합. 더운 날씨 라이딩 필수. 약 35서빙.",
    price: 28000, stock_quantity: 20,
    images: ["shop/shop_03.jpg"] },
]

products_data.each do |data|
  product = Product.find_or_create_by!(sku: data[:sku]) do |p|
    p.name = data[:name]
    p.brand = data[:brand]
    p.category = data[:category]
    p.description = data[:description]
    p.price = data[:price]
    p.sale_price = data[:sale_price]
    p.stock_quantity = data[:stock_quantity]
  end
  if data[:images] && !product.images.attached?
    attach_image(product, :images, data[:images])
  end
end
puts "  Products: #{products_data.size}개 (with images)"

# ─── Rentals (with images) ───
rentals_data = [
  { name: "Giant TCR Advanced 3 (M)", rental_type: "road", daily_rate: 50000,
    description: "입문자를 위한 카본 로드바이크. Shimano 105 R7000 22단, 편안한 엔듀런스 지오메트리. 사이즈 M (170~180cm 권장).",
    images: ["bikes/road/road_bike_07.jpg", "bikes/road/road_bike_08.jpg"] },
  { name: "Trek Domane SL 5 (54cm)", rental_type: "road", daily_rate: 70000,
    description: "장거리 라이딩에 최적화된 엔듀런스 로드바이크. IsoSpeed 충격흡수 기술로 200km도 편안하게. Shimano 105 Di2.",
    images: ["bikes/road/road_bike_04.jpg", "bikes/road/road_bike_09.jpg"] },
  { name: "Specialized Diverge Comp E5 (M)", rental_type: "gravel", daily_rate: 45000,
    description: "그래벨 입문용. Future Shock 서스펜션으로 거친 노면도 편안하게. 700c/650b 휠 호환. GRX 그래벨 전용 구동계.",
    images: ["bikes/road/road_bike_05.jpg", "bikes/mtb/mtb_02.jpg"] },
  { name: "Giant Trance X 29 2 (M)", rental_type: "mtb", daily_rate: 60000,
    description: "트레일 풀서스 MTB. Fox 34 Float (140mm) / Fox Float DPS (120mm). 29인치 휠, Shimano Deore 12단. 대둔산/계룡산 트레일 추천.",
    images: ["bikes/mtb/mtb_03.jpg", "bikes/mtb/mtb_05.jpg"] },
  { name: "Cervélo Caledonia-5 (54cm)", rental_type: "road", daily_rate: 80000,
    description: "프로급 올라운드 로드바이크. SRAM Rival eTap AXS 무선 전자변속. 경쾌한 핸들링과 편안한 승차감을 동시에.",
    images: ["bikes/road/road_bike_03.jpg", "bikes/road/road_bike_10.jpg"] },
]

rentals = rentals_data.map do |data|
  rental = Rental.find_or_create_by!(name: data[:name]) do |r|
    r.rental_type = data[:rental_type]
    r.daily_rate = data[:daily_rate]
    r.description = data[:description]
  end
  if data[:images] && !rental.images.attached?
    attach_image(rental, :images, data[:images])
  end
  rental
end
puts "  Rentals: #{rentals.size}대 (with images)"

# ─── Rental Bookings ───
bookings_data = [
  { rental: 0, customer: 7, start_date: 10.days.from_now.to_date, end_date: 12.days.from_now.to_date, status: "confirmed", notes: "주말 라이딩 체험. 클릿 페달/슈즈 본인 지참." },
  { rental: 1, guest_name: "홍길동", guest_phone: "010-9999-0001", start_date: 3.days.ago.to_date, end_date: 1.day.ago.to_date, status: "returned", notes: "반납 완료, 상태 양호. 다음에 또 대여 예정." },
  { rental: 2, guest_name: "김철수", guest_phone: "010-9999-0002", start_date: Date.today, end_date: 2.days.from_now.to_date, status: "active", notes: "금강 자전거길 그래벨 코스 체험" },
  { rental: 3, guest_name: "이영희", guest_phone: "010-9999-0003", start_date: 15.days.from_now.to_date, end_date: 16.days.from_now.to_date, status: "pending", notes: "대둔산 MTB 트레일 체험 희망. 헬멧/장갑 대여 요청." },
  { rental: 4, guest_name: "박서준", guest_phone: "010-9999-0004", start_date: 5.days.from_now.to_date, end_date: 7.days.from_now.to_date, status: "confirmed", notes: "서울에서 내려오는 라이더. 천안~세종 코스 예정." },
]

bookings_data.each do |data|
  rental = rentals[data[:rental]]
  RentalBooking.find_or_create_by!(rental: rental, start_date: data[:start_date]) do |b|
    b.customer = data[:customer] ? customers[data[:customer]] : nil
    b.end_date = data[:end_date]
    b.guest_name = data[:guest_name]
    b.guest_phone = data[:guest_phone]
    b.status = data[:status]
    b.notes = data[:notes]
  end
end
puts "  RentalBookings: #{bookings_data.size}건"

puts ""
puts "=== 모델하우스 시딩 완료! ==="
puts ""
puts "  📍 주요 페이지:"
puts "  Homepage: http://localhost:3000/"
puts "  Blog: http://localhost:3000/blog"
puts "  Products: http://localhost:3000/products"
puts "  Rentals: http://localhost:3000/rentals"
puts "  Gallery: http://localhost:3000/gallery"
puts ""
puts "  🔐 Admin: http://localhost:3000/admin"
puts "  Email: admin@today.bike"
puts "  Password: password"
puts ""
