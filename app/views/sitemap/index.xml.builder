xml.instruct! :xml, version: "1.0", encoding: "UTF-8"
xml.urlset xmlns: "http://www.sitemaps.org/schemas/sitemap/0.9" do
  # Homepage
  xml.url do
    xml.loc root_url
    xml.changefreq "weekly"
    xml.priority "1.0"
  end

  # Service pages
  %w[overhaul repair fitting upgrade].each do |service_type|
    xml.url do
      xml.loc service_page_url(service_type)
      xml.changefreq "monthly"
      xml.priority "0.8"
    end
  end

  # Blog posts (published)
  @blog_posts.each do |post|
    xml.url do
      xml.loc blog_post_url(post.slug)
      xml.lastmod post.updated_at.iso8601
      xml.changefreq "monthly"
      xml.priority "0.7"
    end
  end

  # Products (active)
  @products.each do |product|
    xml.url do
      xml.loc product_url(product)
      xml.lastmod product.updated_at.iso8601
      xml.changefreq "weekly"
      xml.priority "0.6"
    end
  end

  # Rentals (active)
  @rentals.each do |rental|
    xml.url do
      xml.loc rental_url(rental)
      xml.lastmod rental.updated_at.iso8601
      xml.changefreq "weekly"
      xml.priority "0.6"
    end
  end

  # Gallery
  xml.url do
    xml.loc gallery_url
    xml.changefreq "weekly"
    xml.priority "0.6"
  end

  # Blog index
  xml.url do
    xml.loc blog_url
    xml.changefreq "daily"
    xml.priority "0.7"
  end

  # Products index
  xml.url do
    xml.loc products_url
    xml.changefreq "daily"
    xml.priority "0.7"
  end

  # Rentals index
  xml.url do
    xml.loc rentals_url
    xml.changefreq "daily"
    xml.priority "0.7"
  end
end
