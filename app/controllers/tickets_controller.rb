class TicketsController < ApplicationController
    around_filter :catch_not_found
    before_action :set_ticket, only: [:close, :close_update, :edit, :update, :destroy, :show]
    before_action :grab_subscription
    before_action :grab_all_phone_numbers
    before_action :grab_all_sub_emails

    load_and_authorize_resource :except => [:show]

    def history_notes
        @versions = PaperTrail::Version.order('created_at DESC')
    end
  
    def index
        @tickets = Ticket.active
        @last_weeks_tickets = Ticket.where('created_at >= ?', Date.today - 1.week)
        @ticket_all_properties = Array.new
        @tickets.each do |ticket|
            ticket.properties.each do |property|
                @ticket_all_properties.push(property)            
            end
        end 

        @hash = Gmaps4rails.build_markers(@ticket_all_properties) do |ticket_prop, marker|
            info_window = "<strong>#{ticket_prop.name}</strong><br>#{ticket_prop.address}"
            marker.lat ticket_prop.latitude
            marker.lng ticket_prop.longitude
            marker.infowindow info_window
        end

        respond_to do |format|
            format.html
            format.js
            format.csv { send_data @last_weeks_tickets.generate_csv }
        end
    end

    def show
        @ticket_properties = Array.new
        @ticket.properties.each do |property|
            @ticket_properties.push(property)
        end  

        if @ticket.customers_affected.to_i < 10
            @ca = ActionController::Base.helpers.asset_path("yellow.png")
        elsif @ticket.customers_affected.to_i > 10 && @ticket.customers_affected.to_i <= 99
            @ca = ActionController::Base.helpers.asset_path("orange.png")
        else 
            @ca = ActionController::Base.helpers.asset_path("red.png")
        end

        @hash = Gmaps4rails.build_markers(@ticket_properties) do |ticket_prop, marker|
            info_window = "<strong>#{ticket_prop.name}</strong><br>#{ticket_prop.address}"
            marker.lat ticket_prop.latitude
            marker.lng ticket_prop.longitude
            marker.infowindow info_window
            marker.picture({
                "url" => "#{@ca}",
                "width" =>  "41",        
                "height" => "41"
            })
        end
    end

    def new
        @ticket = Ticket.new
        if @sub_user.nil? 
            redirect_to root_url, :flash => { :alert => "You cannot create a ticket until you subscribe." }
        end
        @testvar = "HELLO WORLD"
    end
  
    def edit
    end

    def close
    end

    def create
        @ticket = Ticket.new(ticket_params)
        @ticket.user_id = current_user.id
        respond_to do |format|
            if @ticket.save
                format.html { redirect_to tickets_url, notice: 'Ticket was successfully created.' }
                format.json { render :show, status: :created, location: @ticket }

                @ticket_categories = []
                @ticket.properties.each do |property|
                    @ticket_categories << property.category.name
                end

                @property_array = []
                @ticket.properties.each do |property|
                    property_full = property.name + " - " + property.address
                    @property_array.push(property_full)
                end

                #code below for emails
                @people_for_emails = @sub_emails.select do |user|
                    intersection = user["categories"] & @ticket_categories
                    intersection.present?
                end

                @emails_for_email = @people_for_emails.map {|emails| emails["name"]}
                UserNotifier.ticket_created(@emails_for_email, @property_array, @ticket.services_affected, @ticket.heat_ticket_number, @ticket.bridge_number, @ticket.customers_affected, @ticket_category, @ticket.event_category, @ticket.event_severity.downcase, @ticket.event_status, @ticket.created_at, @ticket.problem_statement, @ticket.additional_notes, @ticket.attachment).deliver_now            

                #code below for SMS
                @people_for_sms = @people.select do |user|
                    intersection = user["categories"] & @ticket_categories
                    intersection.present?
                end

                @numbers_for_sms = @people_for_sms.map {|numbers| numbers["phone_number"]}
                @numbers_for_sms.each do |pn|
                    #dont send SMS for Maitenance tickets. Emails are fine. 
                    if @ticket.event_category != "Maintenance"
                        @twilio_client.account.messages.create(
                            :from => "+1#{Rails.application.secrets.twilio_phone_number}",
                            :to => "#{pn}",
                            :body => "Hello, ticket ##{@ticket.heat_ticket_number} for #{@property_array.map(&:upcase).to_sentence} has been created via ENS. Event severity has been classified as #{@ticket.event_severity.downcase}. Please check your email for details."
                        )
                    end
                end
            
            else
                format.html { render :new }
                format.json { render json: @ticket.errors, status: :unprocessable_entity }
            end
        end
    end

    def update
        respond_to do |format|
            if @ticket.update(ticket_params)
                format.html { redirect_to tickets_url, notice: 'Ticket was successfully updated.' }
                format.json { render :show, status: :ok, location: @ticket }

                @ticket_categories = []
                @ticket.properties.each do |property|
                    @ticket_categories << property.category.name
                end

                @property_array = []
                @ticket.properties.each do |property|
                    property_full = property.name + " - " + property.address
                    @property_array.push(property_full)
                end

                #code below for emails
                @people_for_emails = @sub_emails.select do |user|
                    intersection = user["categories"] & @ticket_categories
                    intersection.present?
                end
               
                @emails_for_email = @people_for_emails.map {|emails| emails["name"]}                
                UserNotifier.ticket_updated(@emails_for_email, @property_array, @ticket.services_affected, @ticket.heat_ticket_number, @ticket.bridge_number, @ticket.customers_affected, @ticket_category, @ticket.event_category, @ticket.event_severity, @ticket.event_status, @ticket.created_at, @ticket.problem_statement, @ticket.additional_notes, @ticket.attachment, @ticket.versions).deliver_now                

                #code below for SMS        
                @people_for_sms = @people.select do |user|
                    intersection = user["categories"] & @ticket_categories
                    intersection.present?
                end

                @numbers_for_sms = @people_for_sms.map {|numbers| numbers["phone_number"]}
                @numbers_for_sms.each do |pn|
                    #dont send SMS for Maitenance tickets. Emails are fine. 
                    if @ticket.event_category != "Maintenance"
                        @twilio_client.account.messages.create(
                            :from => "+1#{Rails.application.secrets.twilio_phone_number}",
                            :to => "#{pn}",
                            :body => "Hello, ticket ##{@ticket.heat_ticket_number} has been updated via ENS. Please check your email for details."
                        )
                    end
                end
            else
                format.html { render :edit }
                format.json { render json: @ticket.errors, status: :unprocessable_entity }
            end
        end
    end

    def close_update
        respond_to do |format|
            if @ticket.update(ticket_params)
                format.html { redirect_to tickets_url, notice: 'Ticket has been successfully closed.' }
                format.json { render :show, status: :ok, location: @ticket }

                @ticket_categories = []
                @ticket.properties.each do |property|
                    @ticket_categories << property.category.name
                end
                @property_array = []
                @ticket.properties.each do |property|
                    @property_name = property.name
                    @property_array.push(@property_name)
                end

                #TIME ELAPSED FOR TICKET
                @ticket_create = @ticket.created_at.to_time.to_i
                @ticket_complete = @ticket.completed_at.to_time.to_i
                @time_passed = view_context.distance_of_time_in_words(@ticket_create, @ticket_complete)

                #code below for emails
                @people_for_emails = @sub_emails.select do |user|
                    intersection = user["categories"] & @ticket_categories
                    intersection.present?
                end
               
                @emails_for_email = @people_for_emails.map {|emails| emails["name"]}                   
                UserNotifier.ticket_closed(@emails_for_email, @property_array, @ticket.services_affected, @ticket.heat_ticket_number, @ticket_category, @ticket.versions, @ticket.resolution, @time_passed).deliver_now

                #code below for SMS        
                @people_for_sms = @people.select do |user|
                    intersection = user["categories"] & @ticket_categories
                    intersection.present?
                end

                @numbers_for_sms = @people_for_sms.map {|numbers| numbers["phone_number"]}
                @numbers_for_sms.each do |pn|
                    #dont send SMS for Maitenance tickets. Emails are fine. 
                    if @ticket.event_category != "Maintenance"
                        @twilio_client.account.messages.create(
                            :from => "+1#{Rails.application.secrets.twilio_phone_number}",
                            :to => "#{pn}",
                            :body => "Hello, ticket ##{@ticket.heat_ticket_number} has been closed via ENS; please check your email for a more detailed breakdown."
                        )
                    end
                end
            else
                format.html { render :close }
                format.json { render json: @ticket.errors, status: :unprocessable_entity }
            end
        end
    end

    private
        # Use callbacks to share common setup or constraints between actions.
        def set_ticket
            @ticket = Ticket.find(params[:id])
            if @ticket.completed_at != nil 
                redirect_to root_url, :flash => { :alert => "That ticket has already been closed." }
            end
        end 

        def catch_not_found
            yield
        rescue ActiveRecord::RecordNotFound
            redirect_to root_url, :flash => { :alert => "That ticket does not exist." }
        end

        def grab_subscription
            @sub_user = Subscription.find_by_name(current_user.email)
        end

        def grab_all_sub_emails
            @all_users = Subscription.where.not(name: '')
            @sub_emails = @all_users.includes(:categories).map { |user| user.slice(:phone_number, :name).merge(categories: user.categories.map(&:name))}
        end

        def grab_all_phone_numbers
            @all_users = Subscription.where.not(phone_number: '')
            @people = @all_users.includes(:categories).map { |user| user.slice(:phone_number, :name).merge(categories: user.categories.map(&:name))}
            @twilio_client = Twilio::REST::Client.new Rails.application.secrets.twilio_sid, Rails.application.secrets.twilio_token
        end

        def ticket_params
            params.require(:ticket).permit(:attachment, :services_affected, :event_status, :event_severity, :event_category, :problem_statement, :additional_notes, :bridge_number, :heat_ticket_number, :customers_affected, :resolution, :completed_at, :property_ids => [])
        end
end