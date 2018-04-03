#Sample of how to pass in argument
#how to use: rake report:send_to_noc[Date.today - 1.month]
desc "Send Weekly ENS Report"
namespace :report do
  task :send_to_noc_weekly, [:timeframe] => :environment do |t, args|
    ActiveRecord::Base.establish_connection(:development)
    args.with_defaults(:timeframe => (Date.today - 7.days))
    puts "args timeframe: #{args[:timeframe]}"
    Ticket.get_tickets_for_range("ens_report", args[:timeframe])
    ticket = TicketsController.new
    ticket.send_reports
  end
end

desc "Send Monthly ENS Report"
namespace :report do
  task :send_to_noc_monthly, [:timeframe] => :environment do |t, args|
    ActiveRecord::Base.establish_connection(:development)
    args.with_defaults(:timeframe => (Date.today - 30.days))
    puts "args timeframe: #{args[:timeframe]}"
    Ticket.get_tickets_for_range("ens_report", args[:timeframe])
    ticket = TicketsController.new
    ticket.send_reports
  end
end