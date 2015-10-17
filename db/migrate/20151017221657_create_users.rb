class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :phone_number
      t.string :carrier
      t.string :username
      t.string :pin

      t.timestamps null: false
    end
  end
end
