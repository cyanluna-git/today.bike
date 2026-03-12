require "test_helper"

class SitemapControllerTest < ActionDispatch::IntegrationTest
  setup do
    @published_post = blog_posts(:published_post)
    @draft_post = blog_posts(:draft_post)
    @active_product = products(:chain)
    @inactive_product = products(:inactive_product)
    @active_rental = rentals(:cervelo)
    @inactive_rental = rentals(:inactive_rental)
  end

  test "index renders XML sitemap successfully" do
    get sitemap_path(format: :xml)
    assert_response :ok
    assert_equal "application/xml; charset=utf-8", response.content_type
  end

  test "sitemap includes homepage" do
    get sitemap_path(format: :xml)
    assert_match root_url, response.body
  end

  test "sitemap includes service pages" do
    get sitemap_path(format: :xml)
    %w[overhaul repair fitting upgrade].each do |service_type|
      assert_match service_page_url(service_type), response.body
    end
  end

  test "sitemap includes published blog posts" do
    get sitemap_path(format: :xml)
    assert_match blog_post_url(@published_post.slug), response.body
  end

  test "sitemap does not include draft blog posts" do
    get sitemap_path(format: :xml)
    assert_no_match blog_post_url(@draft_post.slug), response.body
  end

  test "sitemap includes active products" do
    get sitemap_path(format: :xml)
    assert_match product_url(@active_product), response.body
  end

  test "sitemap does not include inactive products" do
    get sitemap_path(format: :xml)
    assert_no_match product_url(@inactive_product), response.body
  end

  test "sitemap includes active rentals" do
    get sitemap_path(format: :xml)
    assert_match rental_url(@active_rental), response.body
  end

  test "sitemap does not include inactive rentals" do
    get sitemap_path(format: :xml)
    assert_no_match rental_url(@inactive_rental), response.body
  end

  test "sitemap includes gallery page" do
    get sitemap_path(format: :xml)
    assert_match gallery_url, response.body
  end

  test "sitemap includes blog index" do
    get sitemap_path(format: :xml)
    assert_match blog_url, response.body
  end

  test "sitemap includes products index" do
    get sitemap_path(format: :xml)
    assert_match products_url, response.body
  end

  test "sitemap includes rentals index" do
    get sitemap_path(format: :xml)
    assert_match rentals_url, response.body
  end

  test "sitemap is valid XML with urlset root" do
    get sitemap_path(format: :xml)
    assert_match '<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">', response.body
  end
end
