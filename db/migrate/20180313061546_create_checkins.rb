class CreateCheckins < ActiveRecord::Migration[5.1]
  def change
    create_table :checkins do |t|
      t.string :name
      t.string :time
      t.integer :lat
      t.integer :lng
      t.string :user_id
      t.timestamps
    end
  end
end
