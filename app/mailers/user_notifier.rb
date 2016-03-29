class UserNotifier < ApplicationMailer
	default :from => ENV["SENDGRID_EMAIL_FROM"]

	def send_subscription_created_email(subscriber)
		@subscriber = subscriber
		mail(:to => ENV["SENDGRID_EMAIL_FROM"],
    	:subject => "ENS - #{@subscriber} has subscribed!")
	end

	def ticket_created(user, property_array, heat_ticket_number, bridge_number, customers_affected, ticket_category, event_category, event_severity, event_status, created_at, problem_statement, additional_notes, attachment)
		@property_array = property_array
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
    	mail(:to => user,
    	:subject => "ENS - A Ticket Has Been Created for: #{@property_array.map(&:upcase).to_sentence}")
  	end

  	def ticket_updated(user, property_array, heat_ticket_number, bridge_number, customers_affected, ticket_category, event_category, event_severity, event_status, created_at, problem_statement, additional_notes, versions)
		@property_array = property_array
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
		@versions = versions
    	mail(:to => user,
    	:subject => "ENS - Ticket##{@heat_ticket_number} has been updated for: #{@property_array.map(&:upcase).to_sentence}")
  	end

  	def ticket_closed(user, property_array, heat_ticket_number, ticket_category, resolution)
		@property_array = property_array
		@heat_ticket_number = heat_ticket_number
		@ticket_category = ticket_category
		@resolution = resolution
    	mail(:to => user,
    	:subject => "ENS - Ticket##{@heat_ticket_number} has been closed for: #{@property_array.map(&:upcase).to_sentence}")
  	end
end
