class CreateComments < ActiveRecord::Migration[7.1]
  def change
    create_table :comments do |t|
      t.string :name
      t.text :message
      t.boolean :is_spam

      t.timestamps
    end
  end
end
