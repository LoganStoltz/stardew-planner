require 'sinatra'
require 'json'
require 'rack/cors'

def crops_data
  file_path = File.expand_path('data/crops.json', __dir__)
  JSON.parse(File.read(file_path))
end

def economy_for(crop)
  crop.fetch('economy', {})
end

def crop_sell_price(crop, quality)
  economy_for(crop).dig('sell_prices', quality).to_i
end

def crop_yield(crop)
  amount = economy_for(crop)['yield'].to_i
  amount.positive? ? amount : 1
end

def crop_harvests(crop, days)
  growth_days = economy_for(crop)['growth_days'].to_i
  return 0 if growth_days <= 0 || days < growth_days

  regrow_days = economy_for(crop)['regrow_days']
  return 1 if regrow_days.nil?

  extra_harvests = (days - growth_days) / regrow_days.to_i
  1 + extra_harvests
end

def crop_profit(crop, days, quality)
  harvests = crop_harvests(crop, days)
  return 0 if harvests.zero?

  revenue = harvests * crop_yield(crop) * crop_sell_price(crop, quality)
  seed_cost = economy_for(crop)['seed_price'].to_i
  revenue - seed_cost
end

def days_remaining_in_season(day_in_season, season_length = 28)
  safe_day = [[day_in_season.to_i, 1].max, season_length].min
  season_length - safe_day + 1
end

def param_true?(value, default: true)
  return default if value.nil?

  %w[true 1 yes on].include?(value.to_s.downcase)
end

def oasis_only?(crop)
  sources = crop.dig('availability', 'sources') || []
  sources.any? { |s| s['location'] == 'Oasis' }
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
  day_in_season = params['days'].to_i
  days = days_remaining_in_season(day_in_season)
  budget = params['budget'].to_i
  include_ancient_fruit = param_true?(params['includeAncientFruit'])
  include_sweet_gem_berry = param_true?(params['includeSweetGemBerry'])
  include_oasis = param_true?(params['includeOasis'])
  quality = params['quality']&.downcase || 'regular'

  quality = 'regular' unless %w[regular silver gold].include?(quality)

  seasonal_crops = crops_data.select { |crop| crop.fetch('seasons', []).include?(season) }

  filtered_crops = seasonal_crops.reject do |crop|
    crop_name = crop['name']
    (!include_ancient_fruit && crop_name == 'Ancient Fruit') ||
      (!include_sweet_gem_berry && crop_name == 'Sweet Gem Berry') ||
       (!include_oasis && oasis_only?(crop))
  end

  scored = filtered_crops.map do |crop|
    harvests = crop_harvests(crop, days)
    crop_yield_amount = crop_yield(crop)
    crop_sell_amount = crop_sell_price(crop, quality)
    seed_price = economy_for(crop)['seed_price'].to_i
    revenue = harvests * crop_yield_amount * crop_sell_amount
    {
      name: crop['name'],
      harvests: harvests,
      profit: revenue - seed_price,
      seed_price: seed_price,
      yield: crop_yield_amount,
      sell_price: crop_sell_amount,
      revenue: revenue
    }
  end

  best = scored.max_by { |crop| crop[:profit] }

  content_type :json
  if best.nil? || best[:profit] <= 0
    { error: 'No profitable crop found for those inputs.' }.to_json
  else
    response = {
      best_crop: best[:name],
      profit: best[:profit],
      harvests: best[:harvests],
      quality: quality,
      day_in_season: day_in_season,
      days_remaining: days,
      yield: best[:yield],
      sell_price: best[:sell_price],
      seed_price: best[:seed_price],
      revenue: best[:revenue]
    }

    # Add budget calculations if budget is provided
    if budget > 0
      seed_price = best[:seed_price]
      if seed_price > 0
        seeds_affordable = budget / seed_price
        total_seed_cost = seeds_affordable * seed_price
        lowest_profit = best[:profit] * seeds_affordable

        response.merge!({
          seeds_affordable: seeds_affordable,
          total_seed_cost: total_seed_cost,
          lowest_profit: lowest_profit
        })
      end
    end

    response.to_json
  end
end