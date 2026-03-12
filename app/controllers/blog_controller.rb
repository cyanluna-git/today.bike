class BlogController < ApplicationController
  include Pagy::Backend

  def index
    blog_posts = BlogPost.published.recent
    blog_posts = blog_posts.by_category(params[:category]) if params[:category].present?
    @pagy, @blog_posts = pagy(blog_posts)
  end

  def show
    @blog_post = BlogPost.published.find_by!(slug: params[:slug])
  end
end
