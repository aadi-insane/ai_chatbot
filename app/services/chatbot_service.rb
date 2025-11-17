# app/services/chatbot_service.rb
class ChatbotService
  def initialize
    @client = OpenRouter::Client.new
    @message_limit = 10 # Limit the number of messages sent for context
  end

  def ask_question(question, chat)
    memory = chat.memory&.summary

    # Fetch recent messages from the chat, limited by @message_limit
    recent_messages = chat.messages.order(created_at: :asc).last(@message_limit)

    # Prepare messages for the OpenRouter API
    messages = prepare_messages(recent_messages, question, memory)

    response = @client.complete(
      messages,
      model: [
        "mistralai/mixtral-8x7b-instruct:nitro",
        "mistralai/mixtral-8x7b-instruct",
        "google/gemini-embedding-001"
      ]
    )

    response.dig('choices', 0, 'message', 'content').strip
  rescue StandardError => e
    Rails.logger.error("OpenRouter API error: #{e.message}")
    'Sorry, I am having trouble responding at the moment.'
  end

  private

  def prepare_messages(recent_messages, new_question, memory)
    messages = []

    messages << { role: "system", content: "You are a full-fledged powerful AI chatbot who can do anything." }

    # Add memory if it exists
    messages << { role: "system", content: "Here's a summary of what we've discussed so far: #{memory}" } if memory

    recent_messages.each do |message|
      role = message.sender == 'user' ? 'user' : 'assistant'
      messages << { role: role, content: message.content }
    end

    # Add the new question
    messages << { role: "user", content: new_question }

    messages
  end
end
