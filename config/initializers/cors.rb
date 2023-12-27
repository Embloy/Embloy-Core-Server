# frozen_string_literal: true

Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    origins ENV['CORS_CLIENT_URL']
    resource '*', headers: :any, methods: %i[get post]
  end
  allow do
    origins ENV['CORS_GENIUS_CLIENT_URL']
    resource '*', headers: :any, methods: %i[get post]
  end
end
