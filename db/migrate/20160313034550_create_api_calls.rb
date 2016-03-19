class CreateApiCalls < ActiveRecord::Migration
  def change
    create_table :api_calls do |t|
      t.references :user, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
