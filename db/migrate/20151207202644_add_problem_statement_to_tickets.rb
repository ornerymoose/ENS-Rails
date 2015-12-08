class AddProblemStatementToTickets < ActiveRecord::Migration
  def change
    add_column :tickets, :problem_statement, :text
  end
end
