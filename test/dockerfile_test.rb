require "test_helper"

class DockerfileTest < ActiveSupport::TestCase
  DOCKERFILE = Rails.root.join("Dockerfile").read
  LITESTREAM_YML = Rails.root.join("config", "litestream.yml").read
  ENTRYPOINT = Rails.root.join("bin", "docker-entrypoint").read

  test "Dockerfile contains litestream-download stage" do
    assert_match(/FROM base AS litestream-download/, DOCKERFILE,
      "Dockerfile must define a 'litestream-download' build stage")
  end

  test "Dockerfile copies litestream binary from download stage" do
    assert_match(/COPY --from=litestream-download.*litestream/, DOCKERFILE,
      "Dockerfile must COPY litestream binary from litestream-download stage")
  end

  test "Dockerfile sets RAILS_SERVE_STATIC_FILES" do
    assert_match(/RAILS_SERVE_STATIC_FILES="true"/, DOCKERFILE,
      "Dockerfile must set RAILS_SERVE_STATIC_FILES=true in ENV block")
  end

  test "Dockerfile declares VOLUME /rails/storage" do
    assert_match(/^VOLUME \/rails\/storage$/, DOCKERFILE,
      "Dockerfile must declare VOLUME /rails/storage")
  end

  test "config/litestream.yml exists" do
    assert Rails.root.join("config", "litestream.yml").exist?,
      "config/litestream.yml must exist"
  end

  test "config/litestream.yml references production primary DB" do
    assert_match(/production\.sqlite3/, LITESTREAM_YML,
      "litestream.yml must reference production.sqlite3")
  end

  test "config/litestream.yml references production_cache DB" do
    assert_match(/production_cache\.sqlite3/, LITESTREAM_YML,
      "litestream.yml must reference production_cache.sqlite3")
  end

  test "config/litestream.yml references production_queue DB" do
    assert_match(/production_queue\.sqlite3/, LITESTREAM_YML,
      "litestream.yml must reference production_queue.sqlite3")
  end

  test "config/litestream.yml references production_cable DB" do
    assert_match(/production_cable\.sqlite3/, LITESTREAM_YML,
      "litestream.yml must reference production_cable.sqlite3")
  end

  test "config/litestream.yml references all 4 databases" do
    dbs = %w[production production_cache production_queue production_cable]
    dbs.each do |db|
      assert_match(/#{db}\.sqlite3/, LITESTREAM_YML,
        "litestream.yml must reference #{db}.sqlite3")
    end
  end

  test "bin/docker-entrypoint contains litestream conditional" do
    assert_match(/LITESTREAM_REPLICA_ENDPOINT/, ENTRYPOINT,
      "bin/docker-entrypoint must check LITESTREAM_REPLICA_ENDPOINT before starting litestream")
  end

  test "bin/docker-entrypoint starts litestream replicate" do
    assert_match(/litestream replicate/, ENTRYPOINT,
      "bin/docker-entrypoint must invoke 'litestream replicate'")
  end

  test "bin/docker-entrypoint uses litestream.yml config" do
    assert_match(/litestream\.yml/, ENTRYPOINT,
      "bin/docker-entrypoint must reference litestream.yml config file")
  end
end
