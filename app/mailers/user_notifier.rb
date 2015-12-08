class UserNotifier < ApplicationMailer
	default :from => ENV["SENDGRID_EMAIL_FROM"]

	# send a signup email to the user, pass in the user object that   contains the user's email address
	def send_signup_email(user, property_name, heat_ticket_number, bridge_number, customers_affected, ticket_category, event_category, event_severity, event_status, created_at)
		@property_name = property_name
		@heat_ticket_number = heat_ticket_number
		@bridge_number = bridge_number
		@customers_affected = customers_affected
		@ticket_category = ticket_category
		@event_category = event_category
		@event_status = event_status
		@event_severity = event_severity
		@created_at = created_at
    	mail(:to => user,
    	:subject => 'ENS - A Ticket Has Been Created.')
  	end
end
