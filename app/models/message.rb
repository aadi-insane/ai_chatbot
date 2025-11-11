class Message < ApplicationRecord
  belongs_to :chat
  enum sender: { user: 'user', chatbot: 'chatbot' }
end
