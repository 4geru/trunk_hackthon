class CreateEvent < ActiveRecord::Migration
  def change
    create_table :event do |t|
      t.string  :event_name
      t.string :detail
      t.float   :longitude # 経度
      t.float   :latitude  # 経度
      t.datetime  :start_time
      t.datetime  :end_time
      t.timestamps null: false
    end
  end
end
