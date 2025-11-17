class ChatMemoryService
  def initialize(chat)
    @chat = chat
    @client = OpenRouter::Client.new
  end

  def update_memory
    messages = @chat.messages.order(:created_at).last(50)
    conversation_text = messages.map { |m| "#{m.sender}: #{m.content}" }.join("\n")

    prompt = "Summarize this conversation into short keywords or phrases for memory:\n\n#{conversation_text}"

    summary = call_openrouter(prompt)

    memory = @chat.memory || @chat.build_memory
    memory.summary = summary
    memory.save
  end

  private
    def call_openrouter(prompt)
      messages = [{ role: "user", content: prompt }]
      response = @client.complete(
        messages,
        model: "mistralai/mixtral-8x7b-instruct:nitro" # Or another suitable model for summarization
      )
      summary = response.dig('choices', 0, 'message', 'content')&.strip
      summary || "Could not generate summary."
    rescue StandardError => e
      Rails.logger.error("OpenRouter API error during summarization: #{e.message}")
      "Could not generate summary due to an error."
    end
end
