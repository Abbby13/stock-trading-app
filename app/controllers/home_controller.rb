class HomeController < ApplicationController
  def index
    symbol = params[:symbol] || "MSFT"
  
    Rails.cache.fetch("stock-#{symbol}", expires_in: 1.minute) do
      response = AvaApi.fetch_current_price(symbol)
      @symbol = response.dig("Global Quote", "01. symbol")
      @stock_price = response.dig("Global Quote", "05. price")
      { symbol: @symbol, price: @stock_price }
    end.then do |data|
      @symbol = data[:symbol]
      @stock_price = data[:price]
    end
  rescue => e
    @symbol = "Error"
    @stock_price = e.message
  end
end  