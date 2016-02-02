class TicketsController < ApplicationController
  around_filter :catch_not_found
  before_action :set_ticket, only: [:close, :close_update, :edit, :update, :destroy, :show]
  before_action :grab_subscription
  before_action :grab_all_phone_numbers
  before_action :grab_all_sub_emails

  load_and_authorize_resource :except => [:show]

  # GET /tickets
  # GET /tickets.json

  def history
    @versions = PaperTrail::Version.order('created_at DESC')
  end
  
  def index
    #@tickets = Ticket.all
    @tickets = Ticket.active


    @properties = Property.all
    @pj = @properties.to_json(:only => [:id, :name])

    respond_to do |format|
        format.html
        format.json { render :json => @pj}
        format.js
    end
  end

  def show
    @ticket_properties = Array.new
    @ticket.properties.each do |property|
      @ticket_properties.push(property)
    end  

    @hash = Gmaps4rails.build_markers(@ticket_properties) do |ticket_prop, marker|
        info_window = "#{ticket_prop.name}<br>#{ticket_prop.address}"
        marker.lat ticket_prop.latitude
        marker.lng ticket_prop.longitude
        marker.infowindow info_window
    end
  end

  def new
    @ticket = Ticket.new
    if @sub_user.nil? 
        redirect_to root_url, :flash => { :alert => "You cannot create a ticket until you subscribe." }
    end
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

            @ticket.properties.each do |property|
                @ticket_category = property.category.name
            end

            @property_array = []
            @ticket.properties.each do |property|
                @property_name = property.name
                @property_array.push(@property_name)
            end

            #code below for emails
            @people_for_email = @sub_emails.select {|user| user["categories"].include?(@ticket_category)}
            @emails_for_email = @people_for_email.map {|emails| emails["name"]}
            @emails_for_email.each do |email|
                UserNotifier.ticket_created(email, @property_array, @ticket.heat_ticket_number, @ticket.bridge_number, @ticket.customers_affected, @ticket_category, @ticket.event_category, @ticket.event_severity.downcase, @ticket.event_status, @ticket.created_at, @ticket.problem_statement, @ticket.additional_notes).deliver_now            
            end

            #code below for SMS
            @people_for = @people.select {|user| user["categories"].include?(@ticket_category)}
            @numbers_for_sms = @people_for.map {|numbers| numbers["phone_number"]}
            @numbers_for_sms.each do |pn|
                @twilio_client.account.messages.create(
                    :from => "+1#{Rails.application.secrets.twilio_phone_number}",
                    :to => "#{pn}",
                    :body => "Hello, ticket ##{@ticket.heat_ticket_number} for #{@property_array.map(&:upcase).to_sentence} has been created via ENS. Event severity has been classified as #{@ticket.event_severity}. Please check your email for details."
                )
            end
            
        else
            format.html { render :new }
            format.json { render json: @ticket.errors, status: :unprocessable_entity }
        end
    end
end

  # PATCH/PUT /tickets/1
  # PATCH/PUT /tickets/1.json
def update
    respond_to do |format|
        if @ticket.update(ticket_params)
            format.html { redirect_to tickets_url, notice: 'Ticket was successfully updated.' }
            format.json { render :show, status: :ok, location: @ticket }

            @ticket.properties.each do |property|
                @ticket_category = property.category.name
            end

            @property_array = []
            @ticket.properties.each do |property|
                @property_name = property.name
                @property_array.push(@property_name)
            end

            #code below for emails
            @people_for_email = @sub_emails.select {|user| user["categories"].include?(@ticket_category)}
            @emails_for_email = @people_for_email.map {|emails| emails["name"]}
            @emails_for_email.each do |email|
                UserNotifier.ticket_updated(email, @property_array, @ticket.heat_ticket_number, @ticket.bridge_number, @ticket.customers_affected, @ticket_category, @ticket.event_category, @ticket.event_severity, @ticket.event_status, @ticket.created_at, @ticket.problem_statement, @ticket.additional_notes).deliver_now                
            end
            #code below for SMS        
            @people_for = @people.select {|user| user["categories"].include?(@ticket_category)}
            @numbers_for_sms = @people_for.map {|numbers| numbers["phone_number"]}
            @numbers_for_sms.each do |pn|
                @twilio_client.account.messages.create(
                    :from => "+1#{Rails.application.secrets.twilio_phone_number}",
                    :to => "#{pn}",
                    :body => "Hello, ticket ##{@ticket.heat_ticket_number} has been updated via ENS. Please check your email for details."
                )
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

            @ticket.properties.each do |property|
                @ticket_category = property.category.name
            end

            @property_array = []
            @ticket.properties.each do |property|
                @property_name = property.name
                @property_array.push(@property_name)
            end

            #code below for emails
            @people_for_email = @sub_emails.select {|user| user["categories"].include?(@ticket_category)}
            @emails_for_email = @people_for_email.map {|emails| emails["name"]}    
            @emails_for_email.each do |email|
                UserNotifier.ticket_closed(email, @property_array, @ticket.heat_ticket_number, @ticket_category, @ticket.resolution).deliver_now
            end

            #code below for SMS
            @people_for = @people.select {|user| user["categories"].include?(@ticket_category)}
            @numbers_for_sms = @people_for.map {|numbers| numbers["phone_number"]}
            @numbers_for_sms.each do |pn|
                @twilio_client.account.messages.create(
                    :from => "+1#{Rails.application.secrets.twilio_phone_number}",
                    :to => "#{pn}",
                    :body => "Hello, ticket ##{@ticket.heat_ticket_number} has been closed via ENS; please check your email for details. Resolution: #{@ticket.resolution}"
                )
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

    # Never trust parameters from the scary internet, only allow the white list through.
    def ticket_params
      params.require(:ticket).permit(:event_status, :event_severity, :event_category, :problem_statement, :additional_notes, :bridge_number, :heat_ticket_number, :customers_affected, :resolution, :completed_at, :property_ids => [])
    end

end
