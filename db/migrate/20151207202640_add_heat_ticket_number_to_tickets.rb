class AddHeatTicketNumberToTickets < ActiveRecord::Migration
  def change
    add_column :tickets, :heat_ticket_number, :string
  end
end
