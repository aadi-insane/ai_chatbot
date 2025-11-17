Rails.application.routes.draw do
  # Devise routes for users
  devise_for :users

  # Health check route
  get "up", to: "rails/health#show", as: :rails_health_check

  # Chatbot route
  post "chatbot", to: "chatbot#show"

  # Top-level route for creating messages (for new chats)
  post 'messages', to: 'messages#create'

  # Chat and Message resources
  resources :chats, only: [:index, :show, :create, :destroy] do
    resources :messages, only: [:create]
    resource :memory, only: [:show, :edit, :update], controller: 'memories'
  end
  # Root path
  root to: "home#index"
end
