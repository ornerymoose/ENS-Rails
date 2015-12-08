class AddAdditionalNotesToTickets < ActiveRecord::Migration
  def change
    add_column :tickets, :additional_notes, :text
  end
end
