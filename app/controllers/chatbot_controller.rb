class ChatbotController < ApplicationController
  before_action :authenticate_user!
  
  def show
    if params[:question].present?
      response = ChatbotService.new.ask_question(params[:question])
      if response.present?
        render json: { answer: response }
      else
        render json: { error: 'Something went wrong! Response not generated.' }
      end
    else
      render json: { error: 'No Question Provided!' }, status: :unprocessable_content
    end
  end
end