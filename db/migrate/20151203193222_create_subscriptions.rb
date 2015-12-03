class CreateSubscriptions < ActiveRecord::Migration
  def change
    create_table :subscriptions do |t|
      t.string :name
      t.string :phone_number
      t.integer :category_id

      t.timestamps null: false
    end
  end
end
