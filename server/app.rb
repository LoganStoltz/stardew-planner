require 'sinatra'
require 'json'
require 'rack/cors'

def crops_data
  file_path = File.expand_path('data/crops.json', __dir__)
  JSON.parse(File.read(file_path))
end

def crop_harvests(crop, days)
  growth_days = crop['growth_days'].to_i
  return 0 if growth_days <= 0 || days < growth_days

  regrow_days = crop['regrow_days']
  return 1 if regrow_days.nil?

  extra_harvests = (days - growth_days) / regrow_days.to_i
  1 + extra_harvests
end

def crop_profit(crop, days)
  harvests = crop_harvests(crop, days)
  return 0 if harvests.zero?

  revenue = harvests * crop['sell_price'].to_i
  seed_cost = crop['buy_price'].to_i
  revenue - seed_cost
end

use Rack::Cors do
  allow do
    origins '*'
    resource '*', headers: :any, methods: [:get]
  end
end

get '/' do
  "API running"
end

get '/api/best-crops' do
  season = params['season']&.downcase
  days = params['days'].to_i

  seasonal_crops = crops_data.select { |crop| crop['season'] == season }

  scored = seasonal_crops.map do |crop|
    harvests = crop_harvests(crop, days)
    {
      name: crop['name'],
      harvests: harvests,
      profit: crop_profit(crop, days)
    }
  end

  best = scored.max_by { |crop| crop[:profit] }

  content_type :json
  if best.nil? || best[:profit] <= 0
    { error: 'No profitable crop found for those inputs.' }.to_json
  else
    {
      best_crop: best[:name],
      profit: best[:profit],
      harvests: best[:harvests]
    }.to_json
  end
end