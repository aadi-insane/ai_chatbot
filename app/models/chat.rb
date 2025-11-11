class Chat < ApplicationRecord
  belongs_to :user
  has_many :messages
  
  enum status: { active: 0, archived: 1 }
end
