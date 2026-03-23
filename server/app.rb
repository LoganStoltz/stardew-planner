require 'sinatra'
require 'json'
require 'rack/cors'

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
  season = params['season']
  days = params['days'].to_i

  content_type :json
  {
    best_crop: "Strawberry",
    profit: 960,
    harvests: 3
  }.to_json
end