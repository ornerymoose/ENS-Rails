desc "Send Weekly ENS Report"
task send_weekly_report: :environment do
    #ActiveRecord::Base.establish_connection(:production)
    #puts "You are running this rake task in the #{Rails.env} environment."
    Ticket.send_weekly_report
    tickets = TicketsController.new
    tickets.send_reports
end

