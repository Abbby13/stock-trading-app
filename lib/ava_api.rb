# lib/ava_api.rb
require "net/http"
require "uri"
require "json"

class AvaApi
  # === 1) Fetch a single symbol’s live quote
  def self.fetch_current_price(symbol = "MSFT")
    url = URI("https://alpha-vantage.p.rapidapi.com/query" \
              "?function=GLOBAL_QUOTE&symbol=#{symbol}&datatype=json")
    http = Net::HTTP.new(url.host, url.port)
    http.use_ssl = true

    req = Net::HTTP::Get.new(url)
    req["x-rapidapi-host"] = "alpha-vantage.p.rapidapi.com"
    req["x-rapidapi-key"]  = ENV.fetch("STOCK_API_KEY")

    resp = http.request(req)
    JSON.parse(resp.body)
  end

  # === 2) Search symbols by keyword
  def self.search_symbols(keywords)
    esc = URI.encode_www_form_component(keywords)
    url = URI("https://alpha-vantage.p.rapidapi.com/query" \
              "?function=SYMBOL_SEARCH&keywords=#{esc}&datatype=json")

    http = Net::HTTP.new(url.host, url.port)
    http.use_ssl = true

    req = Net::HTTP::Get.new(url)
    req["x-rapidapi-host"] = "alpha-vantage.p.rapidapi.com"
    req["x-rapidapi-key"]  = ENV.fetch("STOCK_API_KEY")

    resp = http.request(req)
    JSON.parse(resp.body)["bestMatches"] || []
  end
end