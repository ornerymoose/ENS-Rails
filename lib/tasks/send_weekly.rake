desc "Send ENS Report"
namespace :report do
  task send_weekly: :environment do
    #ActiveRecord::Base.establish_connection(:production)
    puts "You are running this rake task in the #{Rails.env} environment."
    Ticket.get_tickets_for_range("ens_weekly_test_v1", Date.today - 7.days)
  end
end

