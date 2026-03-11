require "test_helper"

# Smoke tests for Rails 8 project initialization (Task #706)
# Verifies that rails new today-bike was set up correctly:
# SQLite, Tailwind, Hotwire (Turbo + Stimulus), Importmap
class SmokeTest < ActiveSupport::TestCase
  # --- Rails environment ---

  test "Rails is loaded and running in test environment" do
    assert_equal "test", Rails.env
  end

  test "Rails version is 8.x" do
    assert_match(/\A8\./, Rails.version)
  end

  test "application module is TodayBike" do
    assert_equal "TodayBike::Application", Rails.application.class.name
  end

  # --- Critical config files ---

  test "Gemfile exists" do
    assert File.exist?(Rails.root.join("Gemfile"))
  end

  test "Gemfile.lock exists" do
    assert File.exist?(Rails.root.join("Gemfile.lock"))
  end

  test "config/database.yml uses sqlite3 adapter" do
    db_config = Rails.application.config.database_configuration
    adapter = db_config.dig("test", "adapter") || db_config.dig("default", "adapter")
    assert_equal "sqlite3", adapter
  end

  test "config/routes.rb defines health check route" do
    routes_content = File.read(Rails.root.join("config/routes.rb"))
    assert_includes routes_content, "rails/health#show"
  end

  test "config/importmap.rb exists and pins Hotwire" do
    importmap_path = Rails.root.join("config/importmap.rb")
    assert File.exist?(importmap_path)
    content = File.read(importmap_path)
    assert_includes content, "@hotwired/turbo-rails"
    assert_includes content, "@hotwired/stimulus"
  end

  # --- Procfile.dev ---

  test "Procfile.dev exists" do
    assert File.exist?(Rails.root.join("Procfile.dev")),
      "Procfile.dev is required for bin/dev to work"
  end

  test "Procfile.dev defines web and css processes" do
    content = File.read(Rails.root.join("Procfile.dev"))
    assert_match(/\bweb:\s*bin\/rails server/, content)
    assert_match(/\bcss:.*tailwindcss/, content)
  end

  # --- bin/dev and bin/rails executables ---

  test "bin/dev exists and is executable" do
    bin_dev = Rails.root.join("bin/dev")
    assert File.exist?(bin_dev), "bin/dev must exist"
    assert File.executable?(bin_dev), "bin/dev must be executable"
  end

  test "bin/rails exists and is executable" do
    bin_rails = Rails.root.join("bin/rails")
    assert File.exist?(bin_rails)
    assert File.executable?(bin_rails)
  end

  # --- Key gem dependencies ---

  test "sqlite3 gem is available" do
    assert_nothing_raised { require "sqlite3" }
  end

  test "tailwindcss-rails gem is bundled" do
    spec = Gem.loaded_specs["tailwindcss-rails"] || Bundler.load.specs.find { |s| s.name == "tailwindcss-rails" }
    assert spec, "tailwindcss-rails gem must be present in Gemfile.lock"
  end

  test "turbo-rails gem is bundled" do
    spec = Gem.loaded_specs["turbo-rails"] || Bundler.load.specs.find { |s| s.name == "turbo-rails" }
    assert spec, "turbo-rails gem must be present"
  end

  test "stimulus-rails gem is bundled" do
    spec = Gem.loaded_specs["stimulus-rails"] || Bundler.load.specs.find { |s| s.name == "stimulus-rails" }
    assert spec, "stimulus-rails gem must be present"
  end

  test "importmap-rails gem is bundled" do
    spec = Gem.loaded_specs["importmap-rails"] || Bundler.load.specs.find { |s| s.name == "importmap-rails" }
    assert spec, "importmap-rails gem must be present"
  end

  # --- Project layout ---

  test "standard Rails directories exist" do
    %w[app config db lib log public test].each do |dir|
      assert Dir.exist?(Rails.root.join(dir)), "Expected directory #{dir} to exist"
    end
  end

  test "app subdirectories exist" do
    %w[controllers models views helpers javascript assets].each do |dir|
      assert Dir.exist?(Rails.root.join("app", dir)),
        "Expected app/#{dir} to exist"
    end
  end

  test "custom project directories were preserved" do
    %w[docs kanban-board].each do |dir|
      assert Dir.exist?(Rails.root.join(dir)),
        "Custom directory #{dir} must have been preserved during rails new"
    end
  end

  # --- Database connectivity ---

  test "test database connection works" do
    assert_nothing_raised do
      ActiveRecord::Base.connection.execute("SELECT 1")
    end
  end

  # --- Health check route accessible ---

  test "health check route /up is recognized" do
    route = Rails.application.routes.recognize_path("/up", method: :get)
    assert_equal "rails/health", route[:controller]
    assert_equal "show", route[:action]
  end
end
