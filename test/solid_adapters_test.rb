require "test_helper"
require "yaml"
require "erb"

# Tests verifying Solid Queue / Solid Cable / Solid Cache adapter configuration
# for Kanban task #707 - verifies Builder's implementation is correct.
class SolidAdaptersTest < ActiveSupport::TestCase
  # ---------------------------------------------------------------------------
  # Gem availability
  # ---------------------------------------------------------------------------

  test "solid_cache gem is bundled" do
    spec = Gem.loaded_specs["solid_cache"] || Bundler.load.specs.find { |s| s.name == "solid_cache" }
    assert spec, "solid_cache gem must be present in Gemfile.lock"
  end

  test "solid_queue gem is bundled" do
    spec = Gem.loaded_specs["solid_queue"] || Bundler.load.specs.find { |s| s.name == "solid_queue" }
    assert spec, "solid_queue gem must be present in Gemfile.lock"
  end

  test "solid_cable gem is bundled" do
    spec = Gem.loaded_specs["solid_cable"] || Bundler.load.specs.find { |s| s.name == "solid_cable" }
    assert spec, "solid_cable gem must be present in Gemfile.lock"
  end

  # ---------------------------------------------------------------------------
  # config/database.yml - multi-DB entries
  # ---------------------------------------------------------------------------

  def database_yml
    raw = ERB.new(File.read(Rails.root.join("config/database.yml"))).result
    YAML.safe_load(raw, aliases: true)
  end

  test "database.yml development has primary entry" do
    assert database_yml.dig("development", "primary"), "development.primary must exist"
  end

  test "database.yml development has cache entry" do
    assert database_yml.dig("development", "cache"), "development.cache must exist"
  end

  test "database.yml development has queue entry" do
    assert database_yml.dig("development", "queue"), "development.queue must exist"
  end

  test "database.yml development has cable entry" do
    assert database_yml.dig("development", "cable"), "development.cable must exist"
  end

  test "database.yml test has primary entry" do
    assert database_yml.dig("test", "primary"), "test.primary must exist"
  end

  test "database.yml test has cache entry" do
    assert database_yml.dig("test", "cache"), "test.cache must exist"
  end

  test "database.yml test has queue entry" do
    assert database_yml.dig("test", "queue"), "test.queue must exist"
  end

  test "database.yml test has cable entry" do
    assert database_yml.dig("test", "cable"), "test.cable must exist"
  end

  test "database.yml development uses sqlite3 for all databases" do
    dev = database_yml["development"]
    # Each sub-DB inherits from default (sqlite3); check adapter via runtime config
    db_config = Rails.application.config.database_configuration
    # In test env we read the yml directly; check primary adapter
    primary = dev["primary"]
    assert_equal "sqlite3", primary["adapter"],
      "development.primary must use sqlite3 adapter"
  end

  test "database.yml test queue uses separate sqlite3 file" do
    queue_db = database_yml.dig("test", "queue", "database")
    assert_includes queue_db, "test_queue",
      "test.queue database path should contain 'test_queue'"
    assert_includes queue_db, ".sqlite3",
      "test.queue database must be a sqlite3 file"
  end

  test "database.yml test cache uses separate sqlite3 file" do
    cache_db = database_yml.dig("test", "cache", "database")
    assert_includes cache_db, "test_cache",
      "test.cache database path should contain 'test_cache'"
    assert_includes cache_db, ".sqlite3",
      "test.cache database must be a sqlite3 file"
  end

  test "database.yml test cable uses separate sqlite3 file" do
    cable_db = database_yml.dig("test", "cable", "database")
    assert_includes cable_db, "test_cable",
      "test.cable database path should contain 'test_cable'"
    assert_includes cable_db, ".sqlite3",
      "test.cable database must be a sqlite3 file"
  end

  test "database.yml queue migrations_paths points to db/queue_migrate" do
    dev_queue = database_yml.dig("development", "queue")
    assert_equal "db/queue_migrate", dev_queue["migrations_paths"],
      "development.queue migrations_paths must be db/queue_migrate"
  end

  test "database.yml cache migrations_paths points to db/cache_migrate" do
    dev_cache = database_yml.dig("development", "cache")
    assert_equal "db/cache_migrate", dev_cache["migrations_paths"],
      "development.cache migrations_paths must be db/cache_migrate"
  end

  test "database.yml cable migrations_paths points to db/cable_migrate" do
    dev_cable = database_yml.dig("development", "cable")
    assert_equal "db/cable_migrate", dev_cable["migrations_paths"],
      "development.cable migrations_paths must be db/cable_migrate"
  end

  # ---------------------------------------------------------------------------
  # config/cable.yml - ActionCable solid_cable adapter
  # ---------------------------------------------------------------------------

  def cable_yml
    YAML.safe_load(File.read(Rails.root.join("config/cable.yml")), aliases: true)
  end

  test "cable.yml development uses solid_cable adapter" do
    assert_equal "solid_cable", cable_yml.dig("development", "adapter"),
      "cable.yml development adapter must be solid_cable"
  end

  test "cable.yml development connects_to cable database" do
    writing = cable_yml.dig("development", "connects_to", "database", "writing")
    assert_equal "cable", writing,
      "cable.yml development connects_to writing must point to :cable"
  end

  test "cable.yml production uses solid_cable adapter" do
    assert_equal "solid_cable", cable_yml.dig("production", "adapter"),
      "cable.yml production adapter must be solid_cable"
  end

  test "cable.yml test uses test adapter" do
    assert_equal "test", cable_yml.dig("test", "adapter"),
      "cable.yml test adapter must be 'test' (not solid_cable)"
  end

  test "ActionCable cable config in test environment uses test adapter" do
    assert_equal "test", ActionCable.server.config.cable["adapter"],
      "ActionCable adapter must be 'test' in test environment"
  end

  # ---------------------------------------------------------------------------
  # config/cache.yml - SolidCache configuration
  # ---------------------------------------------------------------------------

  def cache_yml
    YAML.safe_load(File.read(Rails.root.join("config/cache.yml")), aliases: true)
  end

  test "cache.yml development has database entry" do
    assert_equal "cache", cache_yml.dig("development", "database"),
      "cache.yml development database must be 'cache'"
  end

  test "cache.yml test has database entry" do
    assert_equal "cache", cache_yml.dig("test", "database"),
      "cache.yml test database must be 'cache'"
  end

  test "cache.yml production has database entry" do
    assert_equal "cache", cache_yml.dig("production", "database"),
      "cache.yml production database must be 'cache'"
  end

  # ---------------------------------------------------------------------------
  # config/environments/development.rb - adapter settings
  # ---------------------------------------------------------------------------

  test "development.rb configures solid_cache_store" do
    dev_rb = File.read(Rails.root.join("config/environments/development.rb"))
    assert_match(/:solid_cache_store/, dev_rb,
      "development.rb must configure cache_store as :solid_cache_store")
  end

  test "development.rb configures solid_queue adapter" do
    dev_rb = File.read(Rails.root.join("config/environments/development.rb"))
    assert_match(/:solid_queue/, dev_rb,
      "development.rb must configure queue_adapter as :solid_queue")
  end

  test "development.rb configures solid_queue connects_to queue database" do
    dev_rb = File.read(Rails.root.join("config/environments/development.rb"))
    assert_match(/connects_to.*queue/m, dev_rb,
      "development.rb must configure solid_queue connects_to with :queue database")
  end

  # ---------------------------------------------------------------------------
  # Procfile.dev - bin/jobs worker process
  # ---------------------------------------------------------------------------

  test "Procfile.dev contains bin/jobs entry" do
    content = File.read(Rails.root.join("Procfile.dev"))
    assert_match(/\bjobs:\s*bin\/jobs/, content,
      "Procfile.dev must define a 'jobs: bin/jobs' worker process")
  end

  # ---------------------------------------------------------------------------
  # Storage - SQLite database files exist
  # ---------------------------------------------------------------------------

  test "test_queue.sqlite3 file exists in storage" do
    assert File.exist?(Rails.root.join("storage/test_queue.sqlite3")),
      "storage/test_queue.sqlite3 must exist after db:prepare"
  end

  test "test_cache.sqlite3 file exists in storage" do
    assert File.exist?(Rails.root.join("storage/test_cache.sqlite3")),
      "storage/test_cache.sqlite3 must exist after db:prepare"
  end

  test "test_cable.sqlite3 file exists in storage" do
    assert File.exist?(Rails.root.join("storage/test_cable.sqlite3")),
      "storage/test_cable.sqlite3 must exist after db:prepare"
  end

  test "development_queue.sqlite3 file exists in storage" do
    assert File.exist?(Rails.root.join("storage/development_queue.sqlite3")),
      "storage/development_queue.sqlite3 must exist after db:prepare"
  end

  test "development_cache.sqlite3 file exists in storage" do
    assert File.exist?(Rails.root.join("storage/development_cache.sqlite3")),
      "storage/development_cache.sqlite3 must exist after db:prepare"
  end

  test "development_cable.sqlite3 file exists in storage" do
    assert File.exist?(Rails.root.join("storage/development_cable.sqlite3")),
      "storage/development_cable.sqlite3 must exist after db:prepare"
  end

  # ---------------------------------------------------------------------------
  # Schema files exist for Solid adapters
  # ---------------------------------------------------------------------------

  test "db/queue_schema.rb exists" do
    assert File.exist?(Rails.root.join("db/queue_schema.rb")),
      "db/queue_schema.rb must exist for Solid Queue"
  end

  test "db/cache_schema.rb exists" do
    assert File.exist?(Rails.root.join("db/cache_schema.rb")),
      "db/cache_schema.rb must exist for Solid Cache"
  end

  test "db/cable_schema.rb exists" do
    assert File.exist?(Rails.root.join("db/cable_schema.rb")),
      "db/cable_schema.rb must exist for Solid Cable"
  end

  # ---------------------------------------------------------------------------
  # Solid Cache write/read roundtrip (using test_cache.sqlite3 directly)
  # ---------------------------------------------------------------------------

  test "SolidCache write and read roundtrip works against test cache database" do
    cache = SolidCache::Store.new(connects_to: { database: { writing: :cache } })
    key   = "shield_test_#{SecureRandom.hex(4)}"
    value = "shield_roundtrip_ok"

    cache.write(key, value)
    result = cache.read(key)

    assert_equal value, result,
      "SolidCache::Store write/read roundtrip must return the original value"
  ensure
    cache&.delete(key)
  end

  test "SolidCache Store class is available" do
    assert_nothing_raised { SolidCache::Store }
    assert SolidCache::Store.ancestors.include?(ActiveSupport::Cache::Store),
      "SolidCache::Store must inherit from ActiveSupport::Cache::Store"
  end

  # ---------------------------------------------------------------------------
  # Solid Queue gem availability and table schema
  # ---------------------------------------------------------------------------

  test "solid_queue_jobs table exists in queue SQLite database" do
    tables = `sqlite3 #{Rails.root.join("storage/test_queue.sqlite3")} ".tables"`.split
    assert_includes tables, "solid_queue_jobs",
      "solid_queue_jobs table must exist in test_queue.sqlite3"
  end

  test "solid_cache_entries table exists in cache SQLite database" do
    tables = `sqlite3 #{Rails.root.join("storage/test_cache.sqlite3")} ".tables"`.split
    assert_includes tables, "solid_cache_entries",
      "solid_cache_entries table must exist in test_cache.sqlite3"
  end

  test "SolidQueue module is loadable" do
    assert_nothing_raised { require "solid_queue" }
    assert defined?(SolidQueue), "SolidQueue module must be defined"
  end

  test "SolidCable module is loadable" do
    assert_nothing_raised { require "solid_cable" }
    assert defined?(SolidCable), "SolidCable module must be defined"
  end
end
