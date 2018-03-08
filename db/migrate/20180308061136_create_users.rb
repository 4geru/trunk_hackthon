class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string  :channel_id
      t.string :status
      t.timestamps null: false
    end
  end
end
