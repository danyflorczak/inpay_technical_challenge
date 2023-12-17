class AddGmailItToEmails < ActiveRecord::Migration[7.1]
  def change
    add_column :emails, :gmail_id, :string
    add_index :emails, :gmail_id, unique: true
  end
end
