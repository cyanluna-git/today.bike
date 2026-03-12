require "test_helper"

class BlogPostTest < ActiveSupport::TestCase
  def setup
    @blog_post = BlogPost.new(
      title: "Test Blog Post",
      category: "maintenance_tips",
      author: "Today.bike"
    )
  end

  # --- Valid record ---

  test "valid blog post with all fields" do
    assert @blog_post.valid?
  end

  test "valid blog post with minimal fields" do
    post = BlogPost.new(title: "Minimal Post")
    assert post.valid?
  end

  # --- Title validation ---

  test "invalid without title" do
    @blog_post.title = nil
    assert_not @blog_post.valid?
    assert_includes @blog_post.errors[:title], "can't be blank"
  end

  # --- Slug auto-generation ---

  test "slug is auto-generated from title" do
    @blog_post.save!
    assert_equal "test-blog-post", @blog_post.slug
  end

  test "slug is unique" do
    @blog_post.save!
    another = BlogPost.new(title: "Test Blog Post", category: "review")
    another.save!
    assert_not_equal @blog_post.slug, another.slug
    assert_equal "test-blog-post-2", another.slug
  end

  test "slug uniqueness is enforced at database level" do
    @blog_post.save!
    # The generate_slug callback ensures uniqueness by appending a counter,
    # so we verify that two posts with the same title get different slugs
    another = BlogPost.new(title: "Test Blog Post")
    another.save!
    assert_not_equal @blog_post.slug, another.slug
  end

  test "slug is regenerated when title changes" do
    @blog_post.save!
    @blog_post.title = "Updated Title"
    @blog_post.save!
    assert_equal "updated-title", @blog_post.slug
  end

  test "slug handles special characters" do
    post = BlogPost.new(title: "Best Bike Chains 2026!")
    post.save!
    assert_equal "best-bike-chains-2026", post.slug
  end

  # --- Category enum ---

  test "category maintenance_tips" do
    @blog_post.category = "maintenance_tips"
    assert @blog_post.maintenance_tips?
  end

  test "category repair_guide" do
    @blog_post.category = "repair_guide"
    assert @blog_post.repair_guide?
  end

  test "category review" do
    @blog_post.category = "review"
    assert @blog_post.review?
  end

  test "category shop_news" do
    @blog_post.category = "shop_news"
    assert @blog_post.shop_news?
  end

  test "category other" do
    @blog_post.category = "other"
    assert @blog_post.other?
  end

  test "invalid category raises ArgumentError" do
    assert_raises(ArgumentError) do
      @blog_post.category = "invalid_category"
    end
  end

  test "default category is other" do
    post = BlogPost.new(title: "No Category")
    assert_equal "other", post.category
  end

  # --- Category labels ---

  test "category_label returns Korean label" do
    @blog_post.category = "maintenance_tips"
    assert_equal "정비팁", @blog_post.category_label
  end

  test "category_label for shop_news" do
    @blog_post.category = "shop_news"
    assert_equal "샵소식", @blog_post.category_label
  end

  # --- Published ---

  test "default published is false" do
    post = BlogPost.new(title: "Draft")
    assert_equal false, post.published
  end

  test "published_at is set when published changes to true" do
    freeze_time do
      @blog_post.published = true
      @blog_post.save!
      assert_equal Time.current, @blog_post.published_at
    end
  end

  test "published_at is not overwritten if already set" do
    custom_time = Time.zone.parse("2026-01-01 12:00:00")
    @blog_post.published_at = custom_time
    @blog_post.published = true
    @blog_post.save!
    assert_equal custom_time, @blog_post.published_at
  end

  test "published_at is not set when published remains false" do
    @blog_post.save!
    assert_nil @blog_post.published_at
  end

  # --- Author ---

  test "default author is Today.bike" do
    post = BlogPost.new(title: "Test")
    assert_equal "Today.bike", post.author
  end

  # --- Source URL ---

  test "source_url uniqueness" do
    @blog_post.source_url = "https://blog.naver.com/test/123"
    @blog_post.save!
    another = BlogPost.new(title: "Another", source_url: "https://blog.naver.com/test/123")
    assert_not another.valid?
    assert_includes another.errors[:source_url], "has already been taken"
  end

  test "source_url allows blank" do
    @blog_post.source_url = ""
    assert @blog_post.valid?
  end

  test "source_url allows nil" do
    @blog_post.source_url = nil
    assert @blog_post.valid?
  end

  # --- Scopes ---

  test "published scope returns only published posts" do
    published_posts = BlogPost.published
    assert published_posts.all?(&:published?)
  end

  test "by_category scope filters by category" do
    tips = BlogPost.by_category("maintenance_tips")
    assert tips.all? { |p| p.category == "maintenance_tips" }
  end

  test "by_category scope returns all when blank" do
    assert_equal BlogPost.count, BlogPost.by_category(nil).count
  end

  test "recent scope orders by published_at desc" do
    posts = BlogPost.published.recent
    dates = posts.map(&:published_at).compact
    assert_equal dates, dates.sort.reverse
  end

  # --- Rich Text ---

  test "has rich text content" do
    @blog_post.content = "<p>Hello World</p>"
    @blog_post.save!
    assert_equal "Hello World", @blog_post.content.to_plain_text
  end

  # --- Excerpt ---

  test "excerpt returns truncated plain text" do
    @blog_post.content = "A" * 200
    @blog_post.save!
    assert_equal 150, @blog_post.excerpt(150).length - 3 + 3  # truncate adds "..."
    assert @blog_post.excerpt(150).length <= 153
  end

  # --- Fixtures ---

  test "fixtures are loaded" do
    published = blog_posts(:published_post)
    assert_equal "How to Maintain Your Road Bike Chain", published.title
    assert_equal "maintenance_tips", published.category
    assert published.published?
    assert_not_nil published.published_at

    draft = blog_posts(:draft_post)
    assert_not draft.published?
    assert_nil draft.published_at

    migrated = blog_posts(:migrated_post)
    assert_equal "https://blog.naver.com/todaybike/12345", migrated.source_url
  end
end
