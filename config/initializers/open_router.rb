require "open_router"

OpenRouter.configure do |config|
  config.access_token = Rails.application.credentials.open_router[:access_token]
  config.site_name = 'my_chatbot'
  config.site_url = 'http://127.0.0.1:3000'
  # config.model = 'google/gemini-embedding-001'
end