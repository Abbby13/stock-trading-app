require 'test_helper'

class UserTest < ActiveSupport::TestCase
  test "factory creates valid user" do
    user = User.create(email: "foo@example.com", password: "password", password_confirmation: "password", role: "trader", approved: false)
    assert user.valid?
  end

  test "invalid without email" do
    user = User.new(password: "password", password_confirmation: "password", role: "trader", approved: false)
    assert_not user.valid?
    assert_includes user.errors[:email], "must not be blank"
  end

  test "defaults to unapproved" do
    user = User.create(email: "bar@example.com", password: "password", password_confirmation: "password", role: "trader")
    assert_not user.approved?
  end
end
