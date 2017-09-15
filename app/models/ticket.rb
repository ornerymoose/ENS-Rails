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

    #will end up removing generate_csv method when send_weekly_report method is in production
    # def self.send_weekly_report
    #     tickets = Ticket.where('created_at >= ?', Date.today - 1.week)
    #     puts "Ticket count for weekly report: #{tickets.count}"
    #     file = "#{Rails.root}/public/ENS_weekly_#{Date.today}_to_#{Date.today - 1.week}_report.csv"
    #     CSV.open(file, 'w') do |csv|
    #         csv << ['Created By','Heat Ticket #','Event Category','Event Severity','Customers Affected','Services Affected','Problem Statement','Created At','Completed At','Duration','Resolution','Event Status','Bridge Number','Additional Notes','Category Name','Properties']
    #         tickets.each do |t|
    #             if !t.completed_at.nil?
    #                 ticket_duration = Time.at(t.completed_at - t.created_at).utc.strftime("%H:%M:%S")
    #             end
    #             #3 lines below for who edited a ticket
    #             widget = Ticket.find(t.id)
    #             v = widget.versions.first
    #             u = User.find_by_id(v.whodunnit)
    #             csv << [u.email, t.heat_ticket_number, t.event_category, t.event_severity, t.customers_affected, t.services_affected, t.problem_statement,t.created_at, t.completed_at, ticket_duration, t.resolution, t.event_status, t.bridge_number, t.additional_notes, t.properties.map {|p| p.category.name}.join(", "), t.properties.map {|p| p.name}.join(", ")]
    #         end      
    #     end   
    # end

    def self.send_report(timeframe)
        tickets = Ticket.where('created_at >= ?', Date.today - timeframe)
        puts "Ticket count for weekly report: #{tickets.count}"
        file = "#{Rails.root}/public/ENS_weekly_#{Date.today}_to_#{Date.today - timeframe}_report.csv"
        CSV.open(file, 'w') do |csv|
            csv << ['Created By','Heat Ticket #','Event Category','Event Severity','Customers Affected','Services Affected','Problem Statement','Created At','Completed At','Duration','Resolution','Event Status','Bridge Number','Additional Notes','Category Name','Properties']
            tickets.each do |t|
                if !t.completed_at.nil?
                    ticket_duration = Time.at(t.completed_at - t.created_at).utc.strftime("%H:%M:%S")
                end
                #3 lines below for who edited a ticket
                widget = Ticket.find(t.id)
                v = widget.versions.first
                u = User.find_by_id(v.whodunnit)
                csv << [u.email, t.heat_ticket_number, t.event_category, t.event_severity, t.customers_affected, t.services_affected, t.problem_statement,t.created_at, t.completed_at, ticket_duration, t.resolution, t.event_status, t.bridge_number, t.additional_notes, t.properties.map {|p| p.category.name}.join(", "), t.properties.map {|p| p.name}.join(", ")]
            end      
        end   
    end

    # def self.send_monthly_report
    #     tickets = Ticket.where('created_at >= ?', Date.today - 30.days)
    #     puts "Ticket count for monthly report: #{tickets.count}"
    #     file = "#{Rails.root}/public/ENS_monthly_#{Date.today}_to_#{Date.today - 30.days}_report.csv"
    #     CSV.open(file, 'w') do |csv|
    #         csv << ['Created By','Heat Ticket #','Event Category','Event Severity','Customers Affected','Services Affected','Problem Statement','Created At','Completed At','Duration','Resolution','Event Status','Bridge Number','Additional Notes','Category Name','Properties']
    #         tickets.each do |t|
    #             if !t.completed_at.nil?
    #                 ticket_duration = Time.at(t.completed_at - t.created_at).utc.strftime("%H:%M:%S")
    #             end
    #             #3 lines below for who edited a ticket
    #             widget = Ticket.find(t.id)
    #             v = widget.versions.first
    #             u = User.find_by_id(v.whodunnit)
    #             csv << [u.email, t.heat_ticket_number, t.event_category, t.event_severity, t.customers_affected, t.services_affected, t.problem_statement,t.created_at, t.completed_at, ticket_duration, t.resolution, t.event_status, t.bridge_number, t.additional_notes, t.properties.map {|p| p.category.name}.join(", "), t.properties.map {|p| p.name}.join(", ")]
    #         end      
    #     end   
    # end

  	def self.generate_csv
        tickets = Ticket.where('created_at >= ?', Date.today - 1.week)
        csv = CSV.generate do |csv|
            #add headers
            csv << ['Created By','Heat Ticket #','Event Category','Event Severity','Customers Affected','Services Affected','Problem Statement','Created At','Completed At','Duration','Resolution','Event Status','Bridge Number','Additional Notes','Category Name','Properties']
            #add data here
            tickets.each do |t|
                if !t.completed_at.nil?
                    ticket_duration = Time.at(t.completed_at - t.created_at).utc.strftime("%H:%M:%S")
                end
                #3 lines below for who edited a ticket
                widget = Ticket.find(t.id)
                v = widget.versions.first
                u = User.find_by_id(v.whodunnit)
                csv << [u.email, t.heat_ticket_number, t.event_category, t.event_severity, t.customers_affected, t.services_affected, t.problem_statement,t.created_at, t.completed_at, ticket_duration, t.resolution, t.event_status, t.bridge_number, t.additional_notes, t.properties.map {|p| p.category.name}.join(", "), t.properties.map {|p| p.name}.join(", ")]
            end      
        end
    end
end
