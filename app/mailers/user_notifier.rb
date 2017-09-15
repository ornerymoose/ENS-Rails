class UserNotifier < ApplicationMailer
	default :from => ENV["SENDGRID_EMAIL_FROM"]

	def send_subscription_created_email(subscriber)
		@subscriber = subscriber
		mail(:to => ENV["SENDGRID_EMAIL_FROM"],
    	:subject => "ENS - #{@subscriber} has subscribed!")
	end

	def ticket_created(user, property_array, services_affected, heat_ticket_number, bridge_number, customers_affected, ticket_category, event_category, event_severity, event_status, created_at, problem_statement, additional_notes, attachment)
		@property_array = property_array
		@services_affected = services_affected
		@heat_ticket_number = heat_ticket_number
		@bridge_number = bridge_number
		@customers_affected = customers_affected
		@ticket_category = ticket_category
		@event_category = event_category
		@event_status = event_status
		@event_severity = event_severity
		@created_at = created_at
		@problem_statement = problem_statement
		@additional_notes = additional_notes
		@attachment = attachment
		headers["X-SMTPAPI"] = { :to => user }.to_json
    	mail(:to => user,
    	:subject => "ENS - Ticket##{@heat_ticket_number} has been created for: #{@property_array.map(&:upcase).to_sentence}")
  	end

  	def ticket_updated(user, property_array, services_affected, heat_ticket_number, bridge_number, customers_affected, ticket_category, event_category, event_severity, event_status, created_at, problem_statement, additional_notes, attachment, versions)
		@property_array = property_array
		@services_affected = services_affected
		@heat_ticket_number = heat_ticket_number
		@bridge_number = bridge_number
		@customers_affected = customers_affected
		@ticket_category = ticket_category
		@event_category = event_category
		@event_status = event_status
		@event_severity = event_severity
		@created_at = created_at
		@problem_statement = problem_statement
		@additional_notes = additional_notes
		@attachment = attachment
		@versions = versions
		headers["X-SMTPAPI"] = { :to => user }.to_json
    	mail(:to => user,
    	:subject => "ENS - Ticket##{@heat_ticket_number} has been updated for: #{@property_array.map(&:upcase).to_sentence}")
  	end

  	def ticket_closed(user, property_array, services_affected, heat_ticket_number, ticket_category, versions, resolution, time_passed, problem_statement)
		@property_array = property_array
		@services_affected = services_affected
		@heat_ticket_number = heat_ticket_number
		@ticket_category = ticket_category
		@versions = versions
		@resolution = resolution
		@time_passed = time_passed
		@problem_statement = problem_statement
		headers["X-SMTPAPI"] = { :to => user }.to_json
    	mail(:to => user,
    	:subject => "ENS - Ticket##{@heat_ticket_number} has been closed for: #{@property_array.map(&:upcase).to_sentence}")
  	end

    def send_report(user, attachment, timeframe)
        attachment = []
        if timeframe == 7
            file = "#{Rails.root}/public/ENS_weekly_#{Date.today}_to_#{Date.today - timeframe}_report.csv"
        else 
            file = "#{Rails.root}/public/ENS_monthly_#{Date.today}_to_#{Date.today - timeframe}_report.csv"
        end

        attachment.push(file)

        attachment.each do |file_to_send|
            attachments["#{file_to_send.split("/").last}"] = File.read("#{file_to_send}")
        end
        
        headers["X-SMTPAPI"] = { :to => user }.to_json
        mail(:to => user, :subject => "ENS Report - #{Date.today - timeframe} to #{Date.today}")
    end
        
    
end
