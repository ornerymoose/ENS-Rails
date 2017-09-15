desc "Send Weekly ENS Report"
task send_weekly_report: :environment do
    ActiveRecord::Base.establish_connection(:production)
    puts "You are running this rake task in the #{Rails.env} environment."
    arg1 = ARGV
    reformatted_arg = arg1.map {|x| x.to_i}.pop
    puts "Object type: #{arg1.class}"
    Ticket.send_report(reformatted_arg)
    tickets = TicketsController.new
    tickets.send_reports(reformatted_arg)
    exit
end

