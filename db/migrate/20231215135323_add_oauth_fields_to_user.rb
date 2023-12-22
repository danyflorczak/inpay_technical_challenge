class AddOauthFieldsToUser < ActiveRecord::Migration[7.1]
  def change
    change_table :users, bulk: true do |t|
      t.string :provider
      t.string :uid
      t.string :token
      t.string :refresh_token
    end
  end
end
