class RemoveCategoryIdFromSubscriptions < ActiveRecord::Migration
  def change
    remove_column :subscriptions, :category_id, :integer
  end
end
