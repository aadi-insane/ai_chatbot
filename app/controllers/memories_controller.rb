class MemoriesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_chat
  before_action :set_memory
  before_action :ensure_memory_exists, only: [:show]

  def show
  end

  # Show the form to edit the memory
  def edit
  end

  # Update the memory summary
  def update
    if @memory.update(params.require(:memory).permit(:summary))
      redirect_to @chat, notice: 'Memory updated successfully.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def set_chat
    @chat = current_user.chats.find(params[:chat_id])
  end

  def set_memory
    @memory = @chat.memory || @chat.build_memory
  end

  def ensure_memory_exists
    if @chat.memory.nil?
      redirect_to @chat, alert: "No memory has been generated for this chat yet."
    end
  end
end