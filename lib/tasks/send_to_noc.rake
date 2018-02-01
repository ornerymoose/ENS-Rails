#Sample of how to pass in argument
#rake report:send_to_noc["#{Date.today - 30.days}"]
desc "Send ENS Report"
namespace :report do
  task :send_to_noc, [:timeframe] => :environment do |t, args|
    ActiveRecord::Base.establish_connection(:production)
    args.with_defaults(:timeframe => (Date.today - 7.days))
    Ticket.get_tickets_for_range("ens_report", args.timeframe)
    ticket = TicketsController.new
    ticket.send_reports
  end
end

