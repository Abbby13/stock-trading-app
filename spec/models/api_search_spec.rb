require "rails_helper"

RSpec.describe "Stock search", type: :request do
  let(:user) { create(:user, approved: true) }

  before do
    allow_any_instance_of(ApplicationController)
      .to receive(:current_user).and_return(user)

    # stub your AVA client
    allow(AvaApi).to receive(:search_symbols)
      .with("FOO")
      .and_return([{ "1. symbol" => "FOO", "2. name" => "Foo Corp" }])
    allow(AvaApi).to receive(:fetch_current_price)
      .with("FOO")
      .and_return("Global Quote" => { "05. price" => "123.45" })
  end

  it "populates @api_stocks on a query" do
    get trader_dashboard_path, params: { query: "FOO" }
    expect(assigns(:api_stocks).first.symbol).to eq("FOO")
    expect(response.body).to include("Foo Corp")
  end
end