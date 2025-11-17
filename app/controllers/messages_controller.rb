class MessagesController < ApplicationController
  before_action :authenticate_user!

  def create
    @chat = find_or_create_chat

    @message = @chat.messages.create!(message_params.merge(sender: :user))

    # Send the message content and chat to ChatbotService
    response = ChatbotService.new.ask_question(@message.content, @chat)

    @bot_message = @chat.messages.create!(sender: :chatbot, content: response)

    ChatMemoryService.new(@chat).update_memory
        render json: {
      chat_id: @chat.id,
      user_message_html: render_to_string(partial: "messages/message", locals: { message: @message }),
      bot_message_html: render_to_string(partial: "messages/message", locals: { message: @bot_message })
    }, status: :created
  rescue => e
    render json: { error: e.message }, status: :unprocessable_entity
  end

  private
    def find_or_create_chat
      if params[:chat_id].present?
        current_user.chats.find(params[:chat_id])
      else
        current_user.chats.create!(status: :active)
      end
    end

    def message_params
      params.require(:message).permit(:content)
    end
end
