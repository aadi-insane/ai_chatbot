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
      format.json do
        html_messages = @messages.map do |message|
          render_to_string(partial: 'messages/message', locals: { message: message }, formats: [:html])
        end
        render json: html_messages
      end
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
