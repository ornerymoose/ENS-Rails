task :send_weekly_report => :environment do
    Ticket.send_weekly_report
end 