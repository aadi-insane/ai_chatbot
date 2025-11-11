# app/services/chatbot_service.rb
class ChatbotService
  def initialize
    @client = OpenRouter::Client.new
  end

  def ask_question(question)
    messages = [
      { role: "system", content: "You are a full-fledged powerfull AI chatbot who can do anything." },
      { role: "user", content: question }
    ]
    response = @client.complete( messages, 
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
end
