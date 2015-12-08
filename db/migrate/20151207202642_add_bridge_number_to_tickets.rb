class AddBridgeNumberToTickets < ActiveRecord::Migration
  def change
    add_column :tickets, :bridge_number, :string
  end
end
