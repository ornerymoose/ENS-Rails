class AddTicketIdToCategorizations < ActiveRecord::Migration
  def change
    add_column :categorizations, :ticket_id, :integer
  end
end
