class AddEventCategoryToTickets < ActiveRecord::Migration
  def change
    add_column :tickets, :event_category, :string
  end
end
