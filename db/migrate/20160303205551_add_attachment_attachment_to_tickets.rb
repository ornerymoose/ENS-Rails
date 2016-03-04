class AddAttachmentAttachmentToTickets < ActiveRecord::Migration
  def self.up
    change_table :tickets do |t|
      t.attachment :attachment
    end
  end

  def self.down
    remove_attachment :tickets, :attachment
  end
end
