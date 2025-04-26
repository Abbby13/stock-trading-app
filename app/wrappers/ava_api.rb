require 'net/http'
require 'uri'
require 'json'

class AvaApi
  def self.fetch_current_price(symbol = "MSFT")
    url = URI("https://alpha-vantage.p.rapidapi.com/query?function=GLOBAL_QUOTE&symbol=#{symbol}&datatype=json")

    http = Net::HTTP.new(url.host, url.port)
    http.use_ssl = true

    request = Net::HTTP::Get.new(url)
    request["x-rapidapi-host"] = "alpha-vantage.p.rapidapi.com"
    request["x-rapidapi-key"] = ENV["STOCK_API_KEY"]

    response = http.request(request)
    JSON.parse(response.body)
  end
end

  