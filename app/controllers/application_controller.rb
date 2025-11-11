class ApplicationController < ActionController::Base
  # Disable CSRF globally for API requests
  protect_from_forgery with: :null_session
end
