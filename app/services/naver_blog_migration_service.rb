require "net/http"
require "uri"
require "nokogiri"

class NaverBlogMigrationService
  NAVER_BLOG_BASE_URL = "https://blog.naver.com".freeze
  NAVER_POST_VIEW_URL = "https://blog.naver.com/PostView.naver".freeze

  attr_reader :blog_id, :report

  def initialize(blog_id)
    @blog_id = blog_id
    @report = { total: 0, success: 0, failed: 0, skipped: 0, errors: [] }
  end

  # Main entry point: fetch post listing, then import each post
  def import
    posts = fetch_post_list
    @report[:total] = posts.size

    posts.each_with_index do |post_data, index|
      puts "Importing post #{index + 1}/#{posts.size}: #{post_data[:title]}..."
      import_single_post(post_data)
    end

    @report
  end

  private

  # Fetch the listing page of the Naver blog and extract post URLs
  # Returns an array of hashes: [{ url:, title:, log_no: }, ...]
  def fetch_post_list
    url = "#{NAVER_BLOG_BASE_URL}/PostList.naver?blogId=#{blog_id}&categoryNo=0&from=postList"
    html = fetch_html(url)
    return [] if html.blank?

    parse_post_list(html)
  rescue StandardError => e
    @report[:errors] << "Failed to fetch post list: #{e.message}"
    []
  end

  # Parse the Naver blog listing page HTML to extract post entries
  def parse_post_list(html)
    doc = Nokogiri::HTML(html)
    posts = []

    # Naver blog listing pages use various structures.
    # Try common selectors for post links.
    doc.css("a[href*='logNo=']").each do |link|
      href = link["href"].to_s
      log_no = href[/logNo=(\d+)/, 1]
      next if log_no.blank?

      title = link.text.strip
      title = "Untitled Post #{log_no}" if title.blank?

      post_url = "#{NAVER_POST_VIEW_URL}?blogId=#{blog_id}&logNo=#{log_no}"

      posts << { url: post_url, title: title, log_no: log_no }
    end

    posts.uniq { |p| p[:log_no] }
  end

  # Import a single post: fetch detail page, extract content, create BlogPost
  def import_single_post(post_data)
    source_url = post_data[:url]

    # Dedup: skip if already imported
    if BlogPost.exists?(source_url: source_url)
      puts "  Skipped (already exists)"
      @report[:skipped] += 1
      return
    end

    html = fetch_html(source_url)
    if html.blank?
      @report[:failed] += 1
      @report[:errors] << "Failed to fetch: #{source_url}"
      return
    end

    parsed = parse_post_detail(html, post_data)
    create_blog_post(parsed)
  rescue StandardError => e
    @report[:failed] += 1
    @report[:errors] << "Error importing #{post_data[:url]}: #{e.message}"
    puts "  Failed: #{e.message}"
  end

  # Parse the detail page HTML to extract title, content, images
  def parse_post_detail(html, post_data)
    doc = Nokogiri::HTML(html)

    # Try to extract the post title from the detail page
    title = doc.at_css(".se-title-text, .pcol1 .itemSubjectBoldfont, #title_1")&.text&.strip
    title = post_data[:title] if title.blank?

    # Try to extract the main content area
    content_element = doc.at_css(".se-main-container, #postViewArea, .post-view")
    content_html = content_element&.inner_html || ""

    # Extract image URLs from the content
    image_urls = []
    doc.css(".se-main-container img, #postViewArea img, .post-view img").each do |img|
      src = img["src"] || img["data-lazy-src"]
      image_urls << src if src.present? && src.start_with?("http")
    end

    {
      title: title,
      content_html: content_html,
      image_urls: image_urls,
      source_url: post_data[:url]
    }
  end

  # Create a BlogPost record from parsed data
  def create_blog_post(parsed)
    blog_post = BlogPost.new(
      title: parsed[:title],
      category: :shop_news,
      author: "Today.bike",
      source_url: parsed[:source_url],
      published: false  # Imported as draft for review
    )

    # Set rich text content
    blog_post.content = parsed[:content_html]

    # Download and attach images as cover image (use the first image)
    if parsed[:image_urls].present?
      attach_cover_image(blog_post, parsed[:image_urls].first)
    end

    if blog_post.save
      @report[:success] += 1
      puts "  Success: #{blog_post.title} (slug: #{blog_post.slug})"
    else
      @report[:failed] += 1
      error_msg = blog_post.errors.full_messages.join(", ")
      @report[:errors] << "Validation failed for '#{parsed[:title]}': #{error_msg}"
      puts "  Failed: #{error_msg}"
    end
  end

  # Download an image from a URL and attach it as cover_image
  def attach_cover_image(blog_post, image_url)
    uri = URI.parse(image_url)
    response = Net::HTTP.get_response(uri)

    if response.is_a?(Net::HTTPSuccess)
      content_type = response["content-type"] || "image/jpeg"
      extension = case content_type
      when /png/ then "png"
      when /webp/ then "webp"
      else "jpg"
      end

      filename = "cover_#{blog_post.slug || 'image'}.#{extension}"
      blog_post.cover_image.attach(
        io: StringIO.new(response.body),
        filename: filename,
        content_type: content_type
      )
    end
  rescue StandardError => e
    puts "  Warning: Could not download cover image: #{e.message}"
  end

  # Fetch HTML from a URL using Net::HTTP
  def fetch_html(url)
    uri = URI.parse(url)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = (uri.scheme == "https")
    http.open_timeout = 10
    http.read_timeout = 15

    request = Net::HTTP::Get.new(uri.request_uri)
    request["User-Agent"] = "Mozilla/5.0 (compatible; TodayBike BlogImporter/1.0)"

    response = http.request(request)

    if response.is_a?(Net::HTTPSuccess)
      response.body.force_encoding("UTF-8")
    else
      nil
    end
  rescue StandardError => e
    puts "  HTTP error: #{e.message}"
    nil
  end
end
