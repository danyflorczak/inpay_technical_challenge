class AddIndexesToEmail < ActiveRecord::Migration[7.1]
  def change
    add_index :emails, :email_date
    add_index :emails, :sender
  end
end
