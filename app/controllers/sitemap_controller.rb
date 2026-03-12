class SitemapController < ApplicationController
  def index
    @blog_posts = BlogPost.published.recent
    @products = Product.active
    @rentals = Rental.active

    respond_to do |format|
      format.xml
    end
  end
end
