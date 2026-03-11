require "test_helper"

class CustomerTest < ActiveSupport::TestCase
  def setup
    @customer = Customer.new(
      name: "홍길동",
      phone: "010-5555-1234",
      email: "hong@example.com"
    )
  end

  # --- Valid record ---

  test "valid customer with all fields" do
    assert @customer.valid?
  end

  test "valid customer with minimal fields (name and phone only)" do
    customer = Customer.new(name: "박민수", phone: "010-3333-4444")
    assert customer.valid?
  end

  # --- Name validations ---

  test "invalid without name" do
    @customer.name = nil
    assert_not @customer.valid?
    assert_includes @customer.errors[:name], "can't be blank"
  end

  test "invalid with blank name" do
    @customer.name = ""
    assert_not @customer.valid?
    assert_includes @customer.errors[:name], "can't be blank"
  end

  # --- Phone validations ---

  test "invalid without phone" do
    @customer.phone = nil
    assert_not @customer.valid?
    assert_includes @customer.errors[:phone], "can't be blank"
  end

  test "invalid with blank phone" do
    @customer.phone = ""
    assert_not @customer.valid?
  end

  test "invalid with duplicate phone" do
    @customer.save!
    duplicate = Customer.new(name: "다른사람", phone: "010-5555-1234")
    assert_not duplicate.valid?
    assert_includes duplicate.errors[:phone], "has already been taken"
  end

  test "valid phone format: 010-1234-5678" do
    @customer.phone = "010-1111-2222"
    assert @customer.valid?
  end

  test "valid phone format: 01012345678 (no hyphens)" do
    @customer.phone = "01012345678"
    assert @customer.valid?
  end

  test "valid phone format: 011-123-4567 (old prefix, 3-digit middle)" do
    @customer.phone = "011-123-4567"
    assert @customer.valid?
  end

  test "valid phone format: 016-1234-5678" do
    @customer.phone = "016-1234-5678"
    assert @customer.valid?
  end

  test "valid phone format: 017-1234-5678" do
    @customer.phone = "017-1234-5678"
    assert @customer.valid?
  end

  test "valid phone format: 018-1234-5678" do
    @customer.phone = "018-1234-5678"
    assert @customer.valid?
  end

  test "valid phone format: 019-1234-5678" do
    @customer.phone = "019-1234-5678"
    assert @customer.valid?
  end

  test "invalid phone format: random string" do
    @customer.phone = "not-a-phone"
    assert_not @customer.valid?
    assert_includes @customer.errors[:phone], "는 올바른 한국 휴대폰 번호 형식이어야 합니다"
  end

  test "invalid phone format: too short" do
    @customer.phone = "010-123"
    assert_not @customer.valid?
  end

  test "invalid phone format: landline number" do
    @customer.phone = "02-1234-5678"
    assert_not @customer.valid?
  end

  test "invalid phone format: international prefix" do
    @customer.phone = "+82-10-1234-5678"
    assert_not @customer.valid?
  end

  # --- Email validations ---

  test "valid with blank email" do
    @customer.email = ""
    assert @customer.valid?
  end

  test "valid with nil email" do
    @customer.email = nil
    assert @customer.valid?
  end

  test "valid email format" do
    @customer.email = "test@example.com"
    assert @customer.valid?
  end

  test "invalid email format: no @" do
    @customer.email = "not-an-email"
    assert_not @customer.valid?
    assert @customer.errors[:email].any?
  end

  test "invalid email format: no domain" do
    @customer.email = "user@"
    assert_not @customer.valid?
  end

  # --- Active default ---

  test "active defaults to true" do
    customer = Customer.create!(name: "기본고객", phone: "010-7777-8888")
    assert_equal true, customer.active
  end

  test "active can be set to false" do
    @customer.active = false
    @customer.save!
    assert_equal false, @customer.reload.active
  end

  # --- Optional fields ---

  test "kakao_uid is optional" do
    @customer.kakao_uid = nil
    assert @customer.valid?
  end

  test "memo is optional" do
    @customer.memo = nil
    assert @customer.valid?
  end

  # --- Search scope ---

  test "search by exact name" do
    results = Customer.search("김철수")
    assert_includes results, customers(:one)
    assert_not_includes results, customers(:two)
  end

  test "search by partial name" do
    results = Customer.search("김")
    assert_includes results, customers(:one)
  end

  test "search by phone number" do
    results = Customer.search("1234")
    assert_includes results, customers(:one)
    assert_not_includes results, customers(:two)
  end

  test "search by partial phone" do
    results = Customer.search("010")
    assert_includes results, customers(:one)
    assert_includes results, customers(:two)
  end

  test "search with blank query returns all" do
    results = Customer.search("")
    assert_includes results, customers(:one)
    assert_includes results, customers(:two)
  end

  test "search with nil query returns all" do
    results = Customer.search(nil)
    assert_includes results, customers(:one)
    assert_includes results, customers(:two)
  end

  test "search with no match returns empty" do
    results = Customer.search("존재하지않는")
    assert_empty results
  end

  test "search is case insensitive for names" do
    customer = Customer.create!(name: "TestUser", phone: "010-2222-3333")
    results = Customer.search("testuser")
    assert_includes results, customer
  end

  test "search handles SQL special characters safely" do
    results = Customer.search("%_")
    # Should not raise and should not match everything
    assert_kind_of ActiveRecord::Relation, results
  end

  # --- Fixtures loaded correctly ---

  test "fixtures are loaded" do
    assert_equal "김철수", customers(:one).name
    assert_equal "이영희", customers(:two).name
  end
end
