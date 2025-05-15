require_relative '../../config/environment'
require 'rspec/rails'

RSpec.describe User, type: :model do
  let(:user) { User.create(email: "test@example.com", password: "password", password_confirmation: "password", role: "trader", approved: false) }
  

  it "is valid with a proper factory" do
    expect(user).to be_valid
  end

  it "is invalid without an email" do
    user.email = nil
    expect(user).not_to be_valid
    expect(user.errors[:email]).to include("must not be blank")
  end
end