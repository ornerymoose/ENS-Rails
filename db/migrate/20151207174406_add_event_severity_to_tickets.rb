class AddEventSeverityToTickets < ActiveRecord::Migration
  def change
    add_column :tickets, :event_severity, :string
  end
end
