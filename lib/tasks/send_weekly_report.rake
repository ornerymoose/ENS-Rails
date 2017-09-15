desc "Send Weekly ENS Report"
task send_weekly_report: :environment do
    ActiveRecord::Base.establish_connection(:production)
    puts "You are running this rake task in the #{Rails.env} environment."
    arg1 = ARGV
    Ticket.send_report(arg1)
    tickets = TicketsController.new
    tickets.send_reports(arg1)
    exit
end

