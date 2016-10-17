class Ticket < ActiveRecord::Base
	has_many :categorizations
	has_many :properties, through: :categorizations
	belongs_to :user
	validates_presence_of :properties, :problem_statement, :additional_notes, :customers_affected, :heat_ticket_number
	validates_presence_of :resolution, on: :close
	has_paper_trail :only => [:additional_notes]
	
	#this will 'hide' tickets from tickets#index page if they have a completed_at value of nil. When a ticket is initially created,
	#it has a value of nil. completed_at will be set to Time.now when the ticket is closed, but not deleted (tickets never get deleted).
	scope :active, ->{
  		where(completed_at: nil)
	}

	#file attachment
	has_attached_file :attachment, :storage => :s3, :s3_credentials => Proc.new{|a| a.instance.s3_credentials }, styles: { medium: "300x300>", thumb: "100x100>" }, default_url: "/images/:style/missing.png", :keep_old_files => true
  	validates_attachment_content_type :attachment, content_type: /\Aimage\/.*\Z/
  	validates_with AttachmentSizeValidator, attributes: :attachment, less_than: 1.megabytes

  	def s3_credentials
    	{:bucket => ENV["AWS_BUCKET"], :access_key_id => ENV["AWS_ACCESS_KEY_ID"], :secret_access_key => ENV["AWS_SECRET_ACCESS_KEY"]}
  	end

  	def self.generate_csv
    	tickets = Ticket.where('created_at >= ?', Date.today - 1.week)
      	csv = CSV.generate( encoding: 'Windows-1251' ) do |csv|
      		# add headers
      		csv << [ 'Created At', 'Completed At', 'Event Status', 'Customers Affected', 'Event Severity', 'Event Category', 'Heat Ticket Number', 'Bridge Number', 'Problem Statement', 'Additional Notes', 'Resolution', 'Services Affected' ]
      		# add data here
      		tickets.each do |ticket|
        		csv << [ ticket.created_at, ticket.completed_at, ticket.event_status, ticket.customers_affected, ticket.event_severity, ticket.event_category, ticket.heat_ticket_number, ticket.bridge_number, ticket.problem_statement, ticket.additional_notes, ticket.resolution, ticket.services_affected ]
      		end      
    	end
  	end

end
