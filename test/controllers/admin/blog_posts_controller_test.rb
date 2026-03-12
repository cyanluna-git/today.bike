require "test_helper"

class Admin::BlogPostsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @admin_user = admin_users(:one)
    @blog_post = blog_posts(:published_post)
  end

  # --- Authentication tests ---

  test "index requires authentication" do
    get admin_blog_posts_path
    assert_redirected_to new_admin_user_session_path
  end

  test "show requires authentication" do
    get admin_blog_post_path(@blog_post)
    assert_redirected_to new_admin_user_session_path
  end

  test "new requires authentication" do
    get new_admin_blog_post_path
    assert_redirected_to new_admin_user_session_path
  end

  test "create requires authentication" do
    post admin_blog_posts_path, params: { blog_post: { title: "Test" } }
    assert_redirected_to new_admin_user_session_path
  end

  test "edit requires authentication" do
    get edit_admin_blog_post_path(@blog_post)
    assert_redirected_to new_admin_user_session_path
  end

  test "update requires authentication" do
    patch admin_blog_post_path(@blog_post), params: { blog_post: { title: "Updated" } }
    assert_redirected_to new_admin_user_session_path
  end

  test "destroy requires authentication" do
    delete admin_blog_post_path(@blog_post)
    assert_redirected_to new_admin_user_session_path
  end

  # --- Index ---

  test "index renders successfully" do
    sign_in @admin_user
    get admin_blog_posts_path
    assert_response :ok
  end

  test "index page title contains 블로그 관리" do
    sign_in @admin_user
    get admin_blog_posts_path
    assert_select "title", text: /블로그 관리/
  end

  test "index displays blog posts in a table" do
    sign_in @admin_user
    get admin_blog_posts_path
    assert_select "table"
    assert_match @blog_post.title, response.body
  end

  test "index has New Blog Post link" do
    sign_in @admin_user
    get admin_blog_posts_path
    assert_select "a[href='#{new_admin_blog_post_path}']", text: /New Blog Post/
  end

  test "index shows category badge" do
    sign_in @admin_user
    get admin_blog_posts_path
    assert_match @blog_post.category_label, response.body
  end

  test "index shows published status" do
    sign_in @admin_user
    get admin_blog_posts_path
    assert_match "Published", response.body
  end

  test "index filters by category" do
    sign_in @admin_user
    get admin_blog_posts_path, params: { category: "maintenance_tips" }
    assert_response :ok
    assert_match @blog_post.title, response.body
  end

  # --- Show ---

  test "show renders successfully" do
    sign_in @admin_user
    get admin_blog_post_path(@blog_post)
    assert_response :ok
  end

  test "show displays blog post details" do
    sign_in @admin_user
    get admin_blog_post_path(@blog_post)
    assert_match @blog_post.title, response.body
    assert_match @blog_post.category_label, response.body
    assert_match @blog_post.author, response.body
  end

  test "show has edit and delete actions" do
    sign_in @admin_user
    get admin_blog_post_path(@blog_post)
    assert_select "a[href='#{edit_admin_blog_post_path(@blog_post)}']", text: "Edit"
    assert_select "form[action='#{admin_blog_post_path(@blog_post)}']"
  end

  test "show has back to blog posts link" do
    sign_in @admin_user
    get admin_blog_post_path(@blog_post)
    assert_select "a[href='#{admin_blog_posts_path}']", text: /Back to Blog Posts/
  end

  # --- New ---

  test "new renders successfully" do
    sign_in @admin_user
    get new_admin_blog_post_path
    assert_response :ok
  end

  test "new renders a form" do
    sign_in @admin_user
    get new_admin_blog_post_path
    assert_select "form"
    assert_select "input[name='blog_post[title]']"
    assert_select "select[name='blog_post[category]']"
    assert_select "input[name='blog_post[published]']"
  end

  # --- Create ---

  test "create with valid params creates blog post and redirects" do
    sign_in @admin_user

    assert_difference "BlogPost.count", 1 do
      post admin_blog_posts_path, params: {
        blog_post: {
          title: "New Blog Post",
          category: "maintenance_tips",
          meta_description: "A test blog post"
        }
      }
    end

    blog_post = BlogPost.last
    assert_redirected_to admin_blog_post_path(blog_post)
    follow_redirect!
    assert_match "Blog post was successfully created", response.body
  end

  test "create generates slug automatically" do
    sign_in @admin_user

    post admin_blog_posts_path, params: {
      blog_post: { title: "Auto Slug Generation Test" }
    }

    blog_post = BlogPost.last
    assert_equal "auto-slug-generation-test", blog_post.slug
  end

  test "create with invalid params re-renders new form" do
    sign_in @admin_user

    assert_no_difference "BlogPost.count" do
      post admin_blog_posts_path, params: {
        blog_post: { title: "" }
      }
    end

    assert_response :unprocessable_entity
  end

  # --- Edit ---

  test "edit renders successfully" do
    sign_in @admin_user
    get edit_admin_blog_post_path(@blog_post)
    assert_response :ok
  end

  test "edit renders a form with existing values" do
    sign_in @admin_user
    get edit_admin_blog_post_path(@blog_post)
    assert_select "input[name='blog_post[title]'][value='#{@blog_post.title}']"
  end

  # --- Update ---

  test "update with valid params updates blog post and redirects" do
    sign_in @admin_user

    patch admin_blog_post_path(@blog_post), params: {
      blog_post: { title: "Updated Title" }
    }

    assert_redirected_to admin_blog_post_path(@blog_post)
    follow_redirect!
    assert_match "Blog post was successfully updated", response.body
    assert_equal "Updated Title", @blog_post.reload.title
  end

  test "update with invalid params re-renders edit form" do
    sign_in @admin_user

    patch admin_blog_post_path(@blog_post), params: {
      blog_post: { title: "" }
    }

    assert_response :unprocessable_entity
  end

  # --- Destroy ---

  test "destroy deletes blog post and redirects to index" do
    sign_in @admin_user

    assert_difference "BlogPost.count", -1 do
      delete admin_blog_post_path(@blog_post)
    end

    assert_redirected_to admin_blog_posts_path
    follow_redirect!
    assert_match "Blog post was successfully deleted", response.body
  end

  # --- Sidebar ---

  test "sidebar has 블로그 관리 link" do
    sign_in @admin_user
    get admin_blog_posts_path
    assert_select "a[href='#{admin_blog_posts_path}']", text: /블로그 관리/
  end
end
