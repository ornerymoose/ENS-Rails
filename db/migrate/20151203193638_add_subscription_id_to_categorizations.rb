class AddSubscriptionIdToCategorizations < ActiveRecord::Migration
  def change
    add_column :categorizations, :subscription_id, :integer
  end
end
