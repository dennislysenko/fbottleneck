class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :access_token
      t.string :token_secret
      t.integer :token_expiry

      t.timestamps null: false
    end
  end
end
