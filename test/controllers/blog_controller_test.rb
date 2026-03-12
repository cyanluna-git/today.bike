require "test_helper"

class BlogControllerTest < ActionDispatch::IntegrationTest
  setup do
    @published_post = blog_posts(:published_post)
    @draft_post = blog_posts(:draft_post)
  end

  # --- Index ---

  test "index renders successfully" do
    get blog_path
    assert_response :ok
  end

  test "index page title contains Blog" do
    get blog_path
    assert_select "title", text: /Blog/
  end

  test "index shows published posts" do
    get blog_path
    assert_match @published_post.title, response.body
  end

  test "index does not show draft posts" do
    get blog_path
    assert_no_match @draft_post.title, response.body
  end

  test "index shows category badges" do
    get blog_path
    assert_match @published_post.category_label, response.body
  end

  test "index filters by category" do
    get blog_path, params: { category: "maintenance_tips" }
    assert_response :ok
    assert_match @published_post.title, response.body
  end

  test "index category filter excludes other categories" do
    get blog_path, params: { category: "shop_news" }
    assert_response :ok
    assert_no_match @published_post.title, response.body
  end

  test "index has category filter tabs" do
    get blog_path
    assert_select "nav[aria-label='Category filter']"
    assert_select "a", text: "All"
  end

  # --- Show ---

  test "show renders successfully for published post" do
    get blog_post_path(@published_post.slug)
    assert_response :ok
  end

  test "show displays blog post title" do
    get blog_post_path(@published_post.slug)
    assert_match @published_post.title, response.body
  end

  test "show displays category badge" do
    get blog_post_path(@published_post.slug)
    assert_match @published_post.category_label, response.body
  end

  test "show displays author" do
    get blog_post_path(@published_post.slug)
    assert_match @published_post.author, response.body
  end

  test "show has meta description" do
    get blog_post_path(@published_post.slug)
    assert_select "meta[name='description'][content=?]", @published_post.meta_description
  end

  test "show has og:title meta tag" do
    get blog_post_path(@published_post.slug)
    assert_select "meta[property='og:title'][content=?]", @published_post.title
  end

  test "show has back to blog link" do
    get blog_post_path(@published_post.slug)
    assert_select "a[href='#{blog_path}']", text: /Back to Blog/
  end

  test "show returns 404 for draft post" do
    get blog_post_path(@draft_post.slug)
    assert_response :not_found
  end

  test "show returns 404 for nonexistent slug" do
    get blog_post_path("nonexistent-slug")
    assert_response :not_found
  end
end
