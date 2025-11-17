class HomeController < ApplicationController
  before_action :authenticate_user!, only: [:index]

  def index
    @chats = current_user.chats.order(created_at: :desc) if user_signed_in?
  end
end
