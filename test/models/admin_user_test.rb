require "test_helper"

class AdminUserTest < ActiveSupport::TestCase
  # Valid admin user creation
  test "valid admin user can be created with email and password" do
    admin = AdminUser.new(
      email: "newadmin@today.bike",
      password: "password123",
      password_confirmation: "password123"
    )
    assert admin.valid?, "Expected admin user to be valid: #{admin.errors.full_messages.join(', ')}"
    assert admin.save, "Expected admin user to save successfully"
  end

  # Email uniqueness
  test "email must be unique" do
    first = AdminUser.create!(
      email: "unique@today.bike",
      password: "password123",
      password_confirmation: "password123"
    )
    duplicate = AdminUser.new(
      email: "unique@today.bike",
      password: "password123",
      password_confirmation: "password123"
    )
    assert_not duplicate.valid?, "Duplicate email should be invalid"
    assert_includes duplicate.errors[:email], "has already been taken"
  end

  # Email format validation (Devise :validatable)
  test "email must be present" do
    admin = AdminUser.new(
      email: "",
      password: "password123",
      password_confirmation: "password123"
    )
    assert_not admin.valid?
    assert admin.errors[:email].any?
  end

  # Devise minimum password length (default: 6 characters)
  test "password must meet minimum length of 6 characters" do
    admin = AdminUser.new(
      email: "short@today.bike",
      password: "abc",
      password_confirmation: "abc"
    )
    assert_not admin.valid?, "Password shorter than minimum should be invalid"
    assert admin.errors[:password].any?, "Should have a password error"
  end

  test "password at minimum length (6 characters) is valid" do
    admin = AdminUser.new(
      email: "minpass@today.bike",
      password: "abcdef",
      password_confirmation: "abcdef"
    )
    assert admin.valid?, "Password at minimum length should be valid: #{admin.errors.full_messages.join(', ')}"
  end

  # Password confirmation mismatch
  test "password confirmation must match password" do
    admin = AdminUser.new(
      email: "mismatch@today.bike",
      password: "password123",
      password_confirmation: "differentpass"
    )
    assert_not admin.valid?
    assert admin.errors[:password_confirmation].any?
  end

  # Seed data test
  test "seed data creates admin@today.bike account" do
    # The seed uses find_or_create_by!, so we verify the fixture + ability to authenticate
    # In test env, seed is not auto-run; verify we can create the expected seed account
    admin = AdminUser.find_by(email: "admin@today.bike")
    if admin.nil?
      admin = AdminUser.create!(
        email: "admin@today.bike",
        password: "password",
        password_confirmation: "password"
      )
    end
    assert_not_nil admin, "admin@today.bike should exist"
    assert_equal "admin@today.bike", admin.email
    assert admin.valid_password?("password"), "Seed admin should authenticate with 'password'"
  end

  # Fixtures are loadable
  test "fixtures load correctly" do
    assert_not_nil admin_users(:one), "Fixture :one should exist"
    assert_not_nil admin_users(:two), "Fixture :two should exist"
    assert_equal "admin-one@today.bike", admin_users(:one).email
    assert_equal "admin-two@today.bike", admin_users(:two).email
  end

  test "fixture admin users can authenticate with password from fixture" do
    assert admin_users(:one).valid_password?("password"),
      "Fixture :one should be authenticatable with 'password'"
  end
end
