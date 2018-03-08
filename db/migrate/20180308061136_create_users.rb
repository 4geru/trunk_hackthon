class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string  :user_id
      t.string :status
      t.string :name
      t.string :image_url
      t.timestamps null: false
    end
  end
end
