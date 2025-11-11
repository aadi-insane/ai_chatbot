class CreateChats < ActiveRecord::Migration[8.1]
  def change
    create_table :chats do |t|
      t.references :user, null: false, foreign_key: true
      t.integer :status, default: 0, null: false
      
      t.timestamps
    end
  end
end
