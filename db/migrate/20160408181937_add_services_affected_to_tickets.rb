class AddServicesAffectedToTickets < ActiveRecord::Migration
  def change
    add_column :tickets, :services_affected, :string
  end
end
