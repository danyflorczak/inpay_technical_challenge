class CreateEmails < ActiveRecord::Migration[7.1]
  def change
    create_table :emails do |t|
      t.string :sender
      t.string :subject
      t.date :email_date
      t.datetime :email_datetime
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
