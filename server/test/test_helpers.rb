require 'minitest/autorun'

ENV['RACK_ENV'] = 'test'
require_relative '../app'

class TestHelpers < Minitest::Test

  # ---------------------------------------------------------------------------
  # economy_for
  # ---------------------------------------------------------------------------

  def test_economy_for_returns_economy_hash
    crop = { 'economy' => { 'seed_price' => 100 } }
    assert_equal({ 'seed_price' => 100 }, economy_for(crop))
  end

  def test_economy_for_returns_empty_hash_when_missing
    assert_equal({}, economy_for({}))
  end

  # ---------------------------------------------------------------------------
  # crop_sell_price
  # ---------------------------------------------------------------------------

  def test_crop_sell_price_returns_correct_price
    crop = { 'economy' => { 'sell_prices' => { 'regular' => 200, 'silver' => 250, 'gold' => 300 } } }
    assert_equal 200, crop_sell_price(crop, 'regular')
    assert_equal 250, crop_sell_price(crop, 'silver')
    assert_equal 300, crop_sell_price(crop, 'gold')
  end

  def test_crop_sell_price_returns_zero_when_missing
    assert_equal 0, crop_sell_price({ 'economy' => {} }, 'regular')
  end

  # ---------------------------------------------------------------------------
  # crop_yield
  # ---------------------------------------------------------------------------

  def test_crop_yield_returns_correct_amount
    crop = { 'economy' => { 'yield' => 3 } }
    assert_equal 3, crop_yield(crop)
  end

  def test_crop_yield_defaults_to_one_when_zero
    crop = { 'economy' => { 'yield' => 0 } }
    assert_equal 1, crop_yield(crop)
  end

  def test_crop_yield_defaults_to_one_when_missing
    assert_equal 1, crop_yield({})
  end

  # ---------------------------------------------------------------------------
  # crop_harvests
  # ---------------------------------------------------------------------------

  def test_crop_harvests_single_harvest_no_regrow
    # Exactly enough days to grow once, no regrow
    crop = { 'economy' => { 'growth_days' => 10, 'regrow_days' => nil } }
    assert_equal 1, crop_harvests(crop, 10)
  end

  def test_crop_harvests_zero_when_not_enough_days
    # One day short of growing
    crop = { 'economy' => { 'growth_days' => 10, 'regrow_days' => nil } }
    assert_equal 0, crop_harvests(crop, 9)
  end

  def test_crop_harvests_multiple_with_regrow
    # growth=10, regrow=5, days=20 → 1 + (20-10)/5 = 1 + 2 = 3
    crop = { 'economy' => { 'growth_days' => 10, 'regrow_days' => 5 } }
    assert_equal 3, crop_harvests(crop, 20)
  end

  def test_crop_harvests_one_when_regrow_but_no_time_for_it
    # growth=10, regrow=5, days=14 → 1 + (14-10)/5 = 1 + 0 = 1
    crop = { 'economy' => { 'growth_days' => 10, 'regrow_days' => 5 } }
    assert_equal 1, crop_harvests(crop, 14)
  end

  def test_crop_harvests_zero_when_growth_days_is_zero
    crop = { 'economy' => { 'growth_days' => 0 } }
    assert_equal 0, crop_harvests(crop, 28)
  end

  # ---------------------------------------------------------------------------
  # crop_profit
  # ---------------------------------------------------------------------------

  def test_crop_profit_calculates_correctly
    # 1 harvest, yield=1, sell=200, seed=50 → revenue=200, profit=150
    crop = { 'economy' => { 'growth_days' => 10, 'regrow_days' => nil, 'yield' => 1,
                            'sell_prices' => { 'regular' => 200 }, 'seed_price' => 50 } }
    assert_equal 150, crop_profit(crop, 10, 'regular')
  end

  def test_crop_profit_with_yield_multiplier
    # 1 harvest, yield=3, sell=100, seed=50 → revenue=300, profit=250
    crop = { 'economy' => { 'growth_days' => 10, 'regrow_days' => nil, 'yield' => 3,
                            'sell_prices' => { 'regular' => 100 }, 'seed_price' => 50 } }
    assert_equal 250, crop_profit(crop, 10, 'regular')
  end

  def test_crop_profit_zero_when_not_enough_days
    crop = { 'economy' => { 'growth_days' => 10, 'regrow_days' => nil, 'yield' => 1,
                            'sell_prices' => { 'regular' => 200 }, 'seed_price' => 50 } }
    assert_equal 0, crop_profit(crop, 5, 'regular')
  end

  def test_crop_profit_uses_quality_price
    # gold price = 300, seed=50, 1 harvest → profit=250
    crop = { 'economy' => { 'growth_days' => 10, 'regrow_days' => nil, 'yield' => 1,
                            'sell_prices' => { 'regular' => 200, 'gold' => 300 }, 'seed_price' => 50 } }
    assert_equal 250, crop_profit(crop, 10, 'gold')
  end

  # ---------------------------------------------------------------------------
  # days_remaining_in_season
  # ---------------------------------------------------------------------------

  def test_days_remaining_day_one
    assert_equal 28, days_remaining_in_season(1)
  end

  def test_days_remaining_mid_season
    assert_equal 15, days_remaining_in_season(14)
  end

  def test_days_remaining_last_day
    assert_equal 1, days_remaining_in_season(28)
  end

  def test_days_remaining_clamps_below_one
    # Day 0 is treated as day 1
    assert_equal 28, days_remaining_in_season(0)
  end

  def test_days_remaining_clamps_above_season_length
    # Day 99 is treated as day 28
    assert_equal 1, days_remaining_in_season(99)
  end

  def test_days_remaining_custom_season_length
    assert_equal 20, days_remaining_in_season(1, 20)
  end

  # ---------------------------------------------------------------------------
  # param_true?
  # ---------------------------------------------------------------------------

  def test_param_true_with_true_string
    assert param_true?('true')
  end

  def test_param_true_with_one_string
    assert param_true?('1')
  end

  def test_param_true_with_yes_string
    assert param_true?('yes')
  end

  def test_param_true_with_on_string
    assert param_true?('on')
  end

  def test_param_true_is_case_insensitive
    assert param_true?('TRUE')
    assert param_true?('Yes')
  end

  def test_param_true_with_false_string
    refute param_true?('false')
  end

  def test_param_true_with_zero_string
    refute param_true?('0')
  end

  def test_param_true_nil_defaults_to_true
    assert param_true?(nil)
  end

  def test_param_true_nil_with_explicit_false_default
    refute param_true?(nil, default: false)
  end

  # ---------------------------------------------------------------------------
  # oasis_only?
  # ---------------------------------------------------------------------------

  def test_oasis_only_returns_true_for_oasis_crop
    crop = { 'availability' => { 'sources' => [
      { 'type' => 'shop', 'vendor' => 'Sandy', 'location' => 'Oasis' }
    ] } }
    assert oasis_only?(crop)
  end

  def test_oasis_only_returns_false_for_non_oasis_crop
    crop = { 'availability' => { 'sources' => [
      { 'type' => 'shop', 'vendor' => 'Pierre', 'location' => "Pierre's General Store" }
    ] } }
    refute oasis_only?(crop)
  end

  def test_oasis_only_returns_false_when_no_availability
    refute oasis_only?({})
  end

  def test_oasis_only_returns_false_when_sources_empty
    crop = { 'availability' => { 'sources' => [] } }
    refute oasis_only?(crop)
  end

  def test_oasis_only_false_when_oasis_is_not_the_only_source
    # Crop available at Oasis AND Pierre's — still returns true (any? match)
    crop = { 'availability' => { 'sources' => [
      { 'type' => 'shop', 'vendor' => 'Pierre', 'location' => "Pierre's General Store" },
      { 'type' => 'shop', 'vendor' => 'Sandy', 'location' => 'Oasis' }
    ] } }
    assert oasis_only?(crop)
  end

  # ---------------------------------------------------------------------------
  # normalized_quality
  # ---------------------------------------------------------------------------

  def test_normalized_quality_accepts_regular
    assert_equal 'regular', normalized_quality('regular')
  end

  def test_normalized_quality_accepts_silver
    assert_equal 'silver', normalized_quality('silver')
  end

  def test_normalized_quality_accepts_gold
    assert_equal 'gold', normalized_quality('gold')
  end

  def test_normalized_quality_is_case_insensitive
    assert_equal 'gold', normalized_quality('GoLd')
  end

  def test_normalized_quality_defaults_to_regular_for_invalid_value
    assert_equal 'regular', normalized_quality('iridium')
  end

  def test_normalized_quality_defaults_to_regular_for_nil
    assert_equal 'regular', normalized_quality(nil)
  end

  # ---------------------------------------------------------------------------
  # greenhouse_days_to_complete_harvests
  # ---------------------------------------------------------------------------

  def test_greenhouse_days_for_single_harvest_returns_growth_days
    crop = { 'economy' => { 'growth_days' => 13, 'regrow_days' => 4 } }
    assert_equal 13, greenhouse_days_to_complete_harvests(crop: crop, harvests: 1)
  end

  def test_greenhouse_days_for_regrow_crop_multiple_harvests
    # 13 + (2-1)*4 = 17
    crop = { 'economy' => { 'growth_days' => 13, 'regrow_days' => 4 } }
    assert_equal 17, greenhouse_days_to_complete_harvests(crop: crop, harvests: 2)
  end

  def test_greenhouse_days_for_regrow_crop_many_harvests
    # 28 + (5-1)*7 = 56
    crop = { 'economy' => { 'growth_days' => 28, 'regrow_days' => 7 } }
    assert_equal 56, greenhouse_days_to_complete_harvests(crop: crop, harvests: 5)
  end

  def test_greenhouse_days_for_non_regrow_crop_multiple_harvests
    # replant each cycle: 12 * 3 = 36
    crop = { 'economy' => { 'growth_days' => 12, 'regrow_days' => nil } }
    assert_equal 36, greenhouse_days_to_complete_harvests(crop: crop, harvests: 3)
  end

  def test_greenhouse_days_clamps_harvests_to_minimum_one
    crop = { 'economy' => { 'growth_days' => 10, 'regrow_days' => 3 } }
    assert_equal 10, greenhouse_days_to_complete_harvests(crop: crop, harvests: 0)
  end

  def test_greenhouse_days_returns_zero_when_growth_days_invalid
    crop = { 'economy' => { 'growth_days' => 0, 'regrow_days' => 3 } }
    assert_equal 0, greenhouse_days_to_complete_harvests(crop: crop, harvests: 3)
  end

  def test_greenhouse_days_handles_zero_regrow_days_as_single_growth_only
    crop = { 'economy' => { 'growth_days' => 13, 'regrow_days' => 0 } }
    assert_equal 13, greenhouse_days_to_complete_harvests(crop: crop, harvests: 4)
  end

  # ---------------------------------------------------------------------------
  # greenhouse_revenue_result
  # ---------------------------------------------------------------------------

  def test_greenhouse_revenue_result_single_harvest_uses_initial_value
    crop = {
      'name' => 'Blueberry',
      'economy' => {
        'growth_days' => 13,
        'regrow_days' => 4,
        'yield' => 3,
        'seed_price' => 80,
        'sell_prices' => { 'regular' => 55, 'gold' => 82 }
      }
    }

    result = greenhouse_revenue_result(crop: crop, crop_count: 10, harvests: 1, quality: 'regular')

    assert_equal 'Blueberry', result['cropName']
    assert_equal 10, result['planted']
    assert_equal 1, result['harvests']
    assert_equal 0, result['futureHarvests']
    assert_equal 13, result['daysToCompleteHarvests']
    assert_equal 30, result['totalItems']
    assert_equal 1650, result['lowestRevenue']
    assert_equal 800, result['totalSeedCost']
    assert_equal 850, result['lowestProfit']
  end

  def test_greenhouse_revenue_result_multiple_harvests_includes_future_cycles
    crop = {
      'name' => 'Blueberry',
      'economy' => {
        'growth_days' => 13,
        'regrow_days' => 4,
        'yield' => 3,
        'seed_price' => 80,
        'sell_prices' => { 'regular' => 55, 'gold' => 82 }
      }
    }

    result = greenhouse_revenue_result(crop: crop, crop_count: 10, harvests: 2, quality: 'regular')

    assert_equal 1, result['futureHarvests']
    assert_equal 17, result['daysToCompleteHarvests']
    assert_equal 60, result['totalItems']
    assert_equal 3300, result['lowestRevenue']
    assert_equal 2500, result['lowestProfit']
  end

  def test_greenhouse_revenue_result_uses_selected_quality
    crop = {
      'name' => 'Blueberry',
      'economy' => {
        'growth_days' => 13,
        'regrow_days' => 4,
        'yield' => 3,
        'seed_price' => 80,
        'sell_prices' => { 'regular' => 55, 'gold' => 82 }
      }
    }

    result = greenhouse_revenue_result(crop: crop, crop_count: 10, harvests: 2, quality: 'gold')
    assert_equal 82, result['selectedSellPrice']
    assert_equal 4920, result['lowestRevenue']
  end

  def test_greenhouse_revenue_result_marks_non_regrow_crops
    crop = {
      'name' => 'Cauliflower',
      'economy' => {
        'growth_days' => 12,
        'regrow_days' => nil,
        'yield' => 1,
        'seed_price' => 80,
        'sell_prices' => { 'regular' => 192 }
      }
    }

    result = greenhouse_revenue_result(crop: crop, crop_count: 5, harvests: 3, quality: 'regular')

    assert_equal false, result['isRegrowCrop']
    assert_nil result['regrowDays']
    assert_equal 36, result['daysToCompleteHarvests']
  end

end
