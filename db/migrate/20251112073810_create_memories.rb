class CreateMemories < ActiveRecord::Migration[8.1]
  def change
    create_table :memories do |t|
      t.references :chat, null: false, foreign_key: true
      t.text :summary

      t.timestamps
    end
  end
end
