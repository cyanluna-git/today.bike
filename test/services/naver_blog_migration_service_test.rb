require "test_helper"

class NaverBlogMigrationServiceTest < ActiveSupport::TestCase
  def setup
    @service = NaverBlogMigrationService.new("test_blog_id")
  end

  test "initializes with blog_id" do
    assert_equal "test_blog_id", @service.blog_id
  end

  test "initializes report with zero counts" do
    assert_equal 0, @service.report[:total]
    assert_equal 0, @service.report[:success]
    assert_equal 0, @service.report[:failed]
    assert_equal 0, @service.report[:skipped]
    assert_equal [], @service.report[:errors]
  end

  test "import returns report hash" do
    # Override fetch_post_list to avoid actual HTTP calls
    def @service.fetch_post_list
      []
    end

    report = @service.import
    assert_kind_of Hash, report
    assert_includes report.keys, :total
    assert_includes report.keys, :success
    assert_includes report.keys, :failed
    assert_includes report.keys, :skipped
  end

  test "skips posts that already exist by source_url" do
    # The migrated_post fixture has source_url set
    existing = blog_posts(:migrated_post)
    post_data = {
      url: existing.source_url,
      title: "Duplicate Post",
      log_no: "12345"
    }

    @service.send(:import_single_post, post_data)

    assert_equal 1, @service.report[:skipped]
    assert_equal 0, @service.report[:success]
  end

  test "creates blog post with shop_news category" do
    parsed = {
      title: "Test Import Post",
      content_html: "<p>Imported content</p>",
      image_urls: [],
      source_url: "https://blog.naver.com/test/unique_#{Time.current.to_i}"
    }

    assert_difference "BlogPost.count", 1 do
      @service.send(:create_blog_post, parsed)
    end

    post = BlogPost.last
    assert_equal "shop_news", post.category
    assert_equal false, post.published
    assert_equal parsed[:source_url], post.source_url
  end

  test "create_blog_post sets category to shop_news for migrated posts" do
    parsed = {
      title: "Category Test #{Time.current.to_i}",
      content_html: "<p>Content</p>",
      image_urls: [],
      source_url: "https://blog.naver.com/test/category_test_#{Time.current.to_i}"
    }

    @service.send(:create_blog_post, parsed)
    post = BlogPost.last
    assert_equal "shop_news", post.category
  end

  test "report tracks failed imports on validation error" do
    parsed = {
      title: "",  # Will fail validation
      content_html: "<p>Content</p>",
      image_urls: [],
      source_url: "https://blog.naver.com/test/fail_#{Time.current.to_i}"
    }

    @service.send(:create_blog_post, parsed)
    assert_equal 1, @service.report[:failed]
    assert @service.report[:errors].any?
  end

  test "dedup prevents re-importing same source_url" do
    source_url = "https://blog.naver.com/test/dedup_#{Time.current.to_i}"

    # First import
    parsed = {
      title: "First Import",
      content_html: "<p>Content</p>",
      image_urls: [],
      source_url: source_url
    }
    @service.send(:create_blog_post, parsed)
    assert_equal 1, @service.report[:success]

    # Second attempt with same source_url
    post_data = { url: source_url, title: "Duplicate", log_no: "99999" }
    @service.send(:import_single_post, post_data)
    assert_equal 1, @service.report[:skipped]
  end
end
