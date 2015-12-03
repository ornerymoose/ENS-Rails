class CreateTickets < ActiveRecord::Migration
  def change
    create_table :tickets do |t|
      t.integer :property_id
      t.string :event_status
      t.string :customers_affected

      t.timestamps null: false
    end
  end
end
