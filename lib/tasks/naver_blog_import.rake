namespace :naver do
  desc "Import blog posts from a Naver blog. Usage: rake naver:import[blog_id]"
  task :import, [ :blog_id ] => :environment do |_t, args|
    blog_id = args[:blog_id]

    if blog_id.blank?
      puts "Error: blog_id is required. Usage: rake naver:import[blog_id]"
      exit 1
    end

    puts "Starting Naver blog import for blog ID: #{blog_id}"

    service = NaverBlogMigrationService.new(blog_id)
    report = service.import

    puts "\n=== Import Report ==="
    puts "Total posts found:  #{report[:total]}"
    puts "Successfully imported: #{report[:success]}"
    puts "Failed:             #{report[:failed]}"
    puts "Skipped (existing): #{report[:skipped]}"
    puts "===================="
  end
end
