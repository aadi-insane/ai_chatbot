class ChatsController < ApplicationController
  before_action :authenticate_user!

  def index
    @chats = current_user.chats.order(created_at: :desc)
  end

  def show
    @chat = current_user.chats.find(params[:id])
    @messages = @chat.messages.order(:created_at)

    respond_to do |format|
      format.html
      format.json { render json: @messages.as_json(only: [:sender, :content]) }
    end
  end

  def create
    @chat = current_user.chats.create!(status: :active)
    redirect_to @chat
  end

  # def destroy
  #   @chat = current_user.chats.find(params[:id])
  #   @chat.destroy
  #   redirect_to root_path, notice: "Chat deleted successfully."
  # end
end
