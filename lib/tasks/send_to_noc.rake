#Sample of how to pass in argument
#how to use: rake report:send_to_noc[1.month.ago]
desc "Send ENS Report"
namespace :report do
  task :send_to_noc, [:timeframe] => :environment do |t, args|
    ActiveRecord::Base.establish_connection(:production)
    args.with_defaults(:timeframe => (Date.today - 7.days))
    Ticket.get_tickets_for_range("ens_report", args[:timeframe])
    ticket = TicketsController.new
    ticket.send_reports
  end
end

