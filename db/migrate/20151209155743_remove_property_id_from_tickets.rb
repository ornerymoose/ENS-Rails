class RemovePropertyIdFromTickets < ActiveRecord::Migration
  def change
    remove_column :tickets, :property_id, :integer
  end
end
