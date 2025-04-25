class AddDefaultToIsSpamInComments < ActiveRecord::Migration[7.1]
  def change
    change_column_default :comments, :is_spam, from: nil, to: false
  end
end