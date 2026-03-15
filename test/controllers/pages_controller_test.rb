require "test_helper"

class PagesControllerTest < ActionDispatch::IntegrationTest
  # --- Home ---

  test "home renders successfully" do
    get root_path
    assert_response :ok
  end

  test "home page title contains Today.bike" do
    get root_path
    assert_select "title", text: /Today\.bike/
  end

  test "home has hero section with shop name" do
    get root_path
    assert_select "h1", text: /Today\.bike/
  end

  test "home has tagline" do
    get root_path
    assert_match "오늘도 자전거와 함께", response.body
  end

  test "home has CTA button" do
    get root_path
    assert_select "a[href='#{service_page_path('overhaul')}']", text: /서비스 보기/
  end

  test "home has inquiry CTA button" do
    get root_path
    assert_select "a[href='#{new_service_inquiry_path(source_page: "home")}']", text: /문의 접수/
  end

  test "home has services overview section with 4 service cards" do
    get root_path
    assert_match "분해정비", response.body
    assert_match "수리", response.body
    assert_match "피팅", response.body
    assert_match "업그레이드", response.body
  end

  test "home has shop info section" do
    get root_path
    assert_match "매장 안내", response.body
    assert_match "서울특별시 강남구 역삼로 123", response.body
  end

  test "home has map placeholder section" do
    get root_path
    assert_match "지도 서비스 준비 중입니다", response.body
  end

  test "home has JSON-LD LocalBusiness structured data" do
    get root_path
    assert_select "script[type='application/ld+json']"
    assert_match "LocalBusiness", response.body
  end

  test "home has og:title meta tag" do
    get root_path
    assert_select "meta[property='og:title']"
  end

  test "home has og:description meta tag" do
    get root_path
    assert_select "meta[property='og:description']"
  end

  test "home has meta description" do
    get root_path
    assert_select "meta[name='description']"
  end

  # --- Service Pages ---

  test "service page renders overhaul" do
    get service_page_path("overhaul")
    assert_response :ok
    assert_match "분해정비", response.body
  end

  test "service page renders repair" do
    get service_page_path("repair")
    assert_response :ok
    assert_match "수리", response.body
  end

  test "service page renders fitting" do
    get service_page_path("fitting")
    assert_response :ok
    assert_match "피팅", response.body
  end

  test "service page renders upgrade" do
    get service_page_path("upgrade")
    assert_response :ok
    assert_match "업그레이드", response.body
  end

  test "service page returns 404 for invalid type" do
    get service_page_path("invalid")
    assert_response :not_found
  end

  test "service page has process steps" do
    get service_page_path("overhaul")
    assert_match "서비스 과정", response.body
  end

  test "service page has pricing section" do
    get service_page_path("overhaul")
    assert_match "요금 안내", response.body
  end

  test "service page has CTA section" do
    get service_page_path("overhaul")
    assert_match "서비스 문의", response.body
    assert_select "a[href='#{new_service_inquiry_path(service_type: "overhaul", source_page: "service")}']", text: /문의 접수하기/
  end

  test "service page has service navigation" do
    get service_page_path("overhaul")
    assert_select "nav[aria-label='Service types']"
  end

  test "service page has meta description" do
    get service_page_path("overhaul")
    assert_select "meta[name='description']"
  end

  test "service page has og:title meta tag" do
    get service_page_path("overhaul")
    assert_select "meta[property='og:title']"
  end

  test "service page title includes service name" do
    get service_page_path("overhaul")
    assert_select "title", text: /분해정비/
  end

  test "service page has breadcrumb back to home" do
    get service_page_path("overhaul")
    assert_select "a[href='#{root_path}']", text: /홈으로/
  end

  # --- Navigation (public header) ---

  test "home page has navigation header" do
    get root_path
    assert_select "header nav"
  end

  test "navigation pill keeps labels on one line" do
    get root_path

    assert_match "overflow-x-auto whitespace-nowrap", response.body
    assert_match "shrink-0 items-center", response.body
    assert_match "hidden whitespace-nowrap sm:inline", response.body
  end

  test "navigation has logo linking to root" do
    get root_path
    assert_select "header a[href='#{root_path}']", text: /Today\.bike/
  end

  test "navigation has service link" do
    get root_path
    assert_select "header a", text: "서비스"
  end

  test "navigation has blog link" do
    get root_path
    assert_select "header a[href='#{blog_path}']", text: "블로그"
  end

  test "navigation has products link" do
    get root_path
    assert_select "header a[href='#{products_path}']", text: "파츠"
  end

  test "navigation has rentals link" do
    get root_path
    assert_select "header a[href='#{rentals_path}']", text: "대여"
  end

  test "navigation has gallery link" do
    get root_path
    assert_select "header a[href='#{gallery_path}']", text: "갤러리"
  end

  test "navigation has mobile hamburger button" do
    get root_path
    assert_select "button[data-action='click->mobile-nav#toggle']"
  end

  test "mobile nav has menu panel" do
    get root_path
    assert_select "[data-mobile-nav-target='menu']"
  end

  test "mobile nav has overlay" do
    get root_path
    assert_select "[data-mobile-nav-target='overlay']"
  end

  test "viewport meta tag is present" do
    get root_path
    assert_select "meta[name='viewport'][content=?]", "width=device-width, initial-scale=1"
  end

  # --- Footer ---

  test "home page has footer" do
    get root_path
    assert_select "footer"
  end

  test "footer has copyright" do
    get root_path
    assert_select "footer", text: /Today\.bike/
  end
end
