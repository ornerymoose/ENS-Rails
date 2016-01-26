class AddResolutionToTickets < ActiveRecord::Migration
  def change
    add_column :tickets, :resolution, :text
  end
end
