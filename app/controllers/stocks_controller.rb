class StocksController < ApplicationController
  def quote
    @symbol = params[:symbol]&.upcase
    if @symbol.present?
      raw    = AvaApi.fetch_current_price(@symbol)
      @price = raw.dig("Global Quote", "05. price")&.to_f
      @error = "No quote found for #{@symbol}" if @price.blank?
    end
  rescue StandardError => e
    @error = "API error: #{e.message}"
  end
end
