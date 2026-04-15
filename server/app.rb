require 'sinatra'
require 'json'
require 'rack/cors'

set :protection, false
set :bind, '0.0.0.0'
set :port, 4567

options '*' do
  200
end

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

def available_in_year?(crop, year)
  requirements = crop.dig('availability', 'requirements') || []
  year_requirements = requirements.select { |req| req['type'] == 'year' }
  return true if year_requirements.empty?

  year_value = [year.to_i, 1].max

  year_requirements.all? do |requirement|
    min_year = requirement['min']
    max_year = requirement['max']

    meets_min = min_year.nil? || year_value >= min_year.to_i
    meets_max = max_year.nil? || year_value <= max_year.to_i

    meets_min && meets_max
  end
end

get '/' do
  "API running"
end

get '/api/crops' do
  content_type :json
  crops_data.to_json
end

get '/api/best-crops' do
  season = params['season']&.downcase
  day_in_season = params['days'].to_i
  days = days_remaining_in_season(day_in_season)
  year = [params['year'].to_i, 1].max
  budget = params['budget'].to_i
  include_ancient_fruit = param_true?(params['includeAncientFruit'])
  include_sweet_gem_berry = param_true?(params['includeSweetGemBerry'])
  include_oasis = param_true?(params['includeOasis'])
  quality = normalized_quality(params['quality'])

  seasonal_crops = crops_data.select { |crop| crop.fetch('seasons', []).include?(season) }

  filtered_crops = seasonal_crops.reject do |crop|
    crop_name = crop['name']
    (!include_ancient_fruit && crop_name == 'Ancient Fruit') ||
      (!include_sweet_gem_berry && crop_name == 'Sweet Gem Berry') ||
       (!include_oasis && oasis_only?(crop)) ||
       !available_in_year?(crop, year)
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

  ranked_crops = scored.sort_by { |crop| -crop[:profit] }.first(5)
  best = ranked_crops.first

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
      revenue: best[:revenue],
      top_crops: ranked_crops.map do |crop|
        {
          name: crop[:name],
          profit: crop[:profit],
          harvests: crop[:harvests],
          revenue: crop[:revenue],
          seed_price: crop[:seed_price],
          yield: crop[:yield],
          sell_price: crop[:sell_price]
        }
      end
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

get '/api/greenhouse-revenue' do
  crop_name = params['cropName'].to_s
  crop_count = params['cropCount'].to_i
  harvests = params['harvests'].to_i
  quality = normalized_quality(params['quality'])

  content_type :json

  return({ error: 'Crop name is required.' }.to_json) if crop_name.empty?
  return({ error: 'Number planted must be at least 1.' }.to_json) if crop_count < 1
  return({ error: 'Harvests must be at least 1.' }.to_json) if harvests < 1

  crop = crops_data.find { |candidate| candidate['name'] == crop_name }
  return({ error: 'Crop not found.' }.to_json) if crop.nil?

  greenhouse_revenue_result(
    crop: crop,
    crop_count: crop_count,
    harvests: harvests,
    quality: quality
  ).to_json
end

def normalized_quality(value)
  quality = value.to_s.downcase
  %w[regular silver gold].include?(quality) ? quality : 'regular'
end

def greenhouse_revenue_result(crop:, crop_count:, harvests:, quality:)
  crop_yield_amount = crop_yield(crop)
  sell_price = crop_sell_price(crop, quality)
  seed_price = economy_for(crop)['seed_price'].to_i
  growth_days = economy_for(crop)['growth_days'].to_i
  regrow_days = economy_for(crop)['regrow_days']
  days_to_complete_harvests = greenhouse_days_to_complete_harvests(crop: crop, harvests: harvests)

  total_items = crop_count * harvests * crop_yield_amount
  lowest_revenue = total_items * sell_price
  total_seed_cost = crop_count * seed_price
  lowest_profit = lowest_revenue - total_seed_cost

  {
    'cropName' => crop['name'],
    'planted' => crop_count,
    'harvests' => harvests,
    'futureHarvests' => [harvests - 1, 0].max,
    'growthDays' => growth_days,
    'regrowDays' => regrow_days,
    'daysToCompleteHarvests' => days_to_complete_harvests,
    'isRegrowCrop' => !regrow_days.nil?,
    'yieldPerHarvest' => crop_yield_amount,
    'quality' => quality,
    'selectedSellPrice' => sell_price,
    'seedPrice' => seed_price,
    'totalItems' => total_items,
    'lowestRevenue' => lowest_revenue,
    'totalSeedCost' => total_seed_cost,
    'lowestProfit' => lowest_profit
  }
end

def greenhouse_days_to_complete_harvests(crop:, harvests:)
  safe_harvests = [harvests.to_i, 1].max
  growth_days = economy_for(crop)['growth_days'].to_i
  return 0 if growth_days <= 0

  regrow_days = economy_for(crop)['regrow_days']
  return growth_days * safe_harvests if regrow_days.nil?

  regrow_days_value = regrow_days.to_i
  return growth_days if safe_harvests == 1 || regrow_days_value <= 0

  growth_days + ((safe_harvests - 1) * regrow_days_value)
end