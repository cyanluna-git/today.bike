require "test_helper"
require "yaml"

class DeployConfigTest < ActiveSupport::TestCase
  DEPLOY_YML = YAML.load_file(Rails.root.join("config", "deploy.yml"))
  DEPLOY_RAW = Rails.root.join("config", "deploy.yml").read
  SECRETS_FILE = Rails.root.join(".kamal", "secrets").read

  # --- Service name ---

  test "service name is today-bike" do
    assert_equal "today-bike", DEPLOY_YML["service"],
      "service must be 'today-bike'"
  end

  # --- Proxy / SSL ---

  test "proxy block exists with ssl enabled" do
    assert DEPLOY_YML.dig("proxy", "ssl"),
      "proxy.ssl must be true for Let's Encrypt auto-cert"
  end

  test "proxy host is today.bike" do
    assert_equal "today.bike", DEPLOY_YML.dig("proxy", "host"),
      "proxy.host must be 'today.bike'"
  end

  # --- Registry ---

  test "registry server is ghcr.io" do
    assert_equal "ghcr.io", DEPLOY_YML.dig("registry", "server"),
      "registry.server must be 'ghcr.io'"
  end

  test "registry has password secret reference" do
    password = DEPLOY_YML.dig("registry", "password")
    assert_includes password, "KAMAL_REGISTRY_PASSWORD",
      "registry.password must reference KAMAL_REGISTRY_PASSWORD"
  end

  # --- Env secrets ---

  test "env secrets include RAILS_MASTER_KEY" do
    secrets = DEPLOY_YML.dig("env", "secret")
    assert_includes secrets, "RAILS_MASTER_KEY",
      "env.secret must include RAILS_MASTER_KEY"
  end

  test "env secrets include SECRET_KEY_BASE" do
    secrets = DEPLOY_YML.dig("env", "secret")
    assert_includes secrets, "SECRET_KEY_BASE",
      "env.secret must include SECRET_KEY_BASE"
  end

  test "env secrets include LITESTREAM_REPLICA_ENDPOINT" do
    secrets = DEPLOY_YML.dig("env", "secret")
    assert_includes secrets, "LITESTREAM_REPLICA_ENDPOINT",
      "env.secret must include LITESTREAM_REPLICA_ENDPOINT"
  end

  test "env secrets include LITESTREAM_REPLICA_BUCKET" do
    secrets = DEPLOY_YML.dig("env", "secret")
    assert_includes secrets, "LITESTREAM_REPLICA_BUCKET",
      "env.secret must include LITESTREAM_REPLICA_BUCKET"
  end

  test "env secrets include LITESTREAM_ACCESS_KEY_ID" do
    secrets = DEPLOY_YML.dig("env", "secret")
    assert_includes secrets, "LITESTREAM_ACCESS_KEY_ID",
      "env.secret must include LITESTREAM_ACCESS_KEY_ID"
  end

  test "env secrets include LITESTREAM_SECRET_ACCESS_KEY" do
    secrets = DEPLOY_YML.dig("env", "secret")
    assert_includes secrets, "LITESTREAM_SECRET_ACCESS_KEY",
      "env.secret must include LITESTREAM_SECRET_ACCESS_KEY"
  end

  # --- Volume mount ---

  test "volumes map to /rails/storage" do
    volumes = DEPLOY_YML["volumes"]
    assert volumes.any? { |v| v.include?(":/rails/storage") },
      "volumes must include a mapping to /rails/storage"
  end

  test "volume name is consistent with service name" do
    volumes = DEPLOY_YML["volumes"]
    assert volumes.any? { |v| v.start_with?("today-bike") },
      "volume name should be consistent with service name 'today-bike'"
  end

  # --- .kamal/secrets ---

  test ".kamal/secrets defines RAILS_MASTER_KEY" do
    assert_match(/^RAILS_MASTER_KEY=/, SECRETS_FILE,
      ".kamal/secrets must define RAILS_MASTER_KEY")
  end

  test ".kamal/secrets defines KAMAL_REGISTRY_PASSWORD" do
    assert_match(/^KAMAL_REGISTRY_PASSWORD=/, SECRETS_FILE,
      ".kamal/secrets must define KAMAL_REGISTRY_PASSWORD")
  end

  test ".kamal/secrets defines SECRET_KEY_BASE" do
    assert_match(/^SECRET_KEY_BASE=/, SECRETS_FILE,
      ".kamal/secrets must define SECRET_KEY_BASE")
  end

  test ".kamal/secrets defines LITESTREAM vars" do
    %w[
      LITESTREAM_REPLICA_ENDPOINT
      LITESTREAM_REPLICA_BUCKET
      LITESTREAM_ACCESS_KEY_ID
      LITESTREAM_SECRET_ACCESS_KEY
    ].each do |var|
      assert_match(/^#{var}=/, SECRETS_FILE,
        ".kamal/secrets must define #{var}")
    end
  end

  # --- No raw credentials ---

  test ".kamal/secrets does not contain raw credentials" do
    # Ensure all values use shell variable expansion ($ prefix) or command substitution
    SECRETS_FILE.each_line do |line|
      next if line.strip.empty? || line.strip.start_with?("#")
      key, value = line.strip.split("=", 2)
      next unless key && value
      assert(value.start_with?("$") || value.start_with?("$("),
        "#{key} value should use shell expansion, not raw credentials")
    end
  end

  # --- Kamal 2 proxy (not traefik) ---

  test "deploy.yml does not reference traefik" do
    refute_match(/traefik/i, DEPLOY_RAW,
      "Kamal 2 uses proxy block, not traefik")
  end
end
