class TicketsController < ApplicationController
  before_action :set_ticket, only: [:show, :edit, :update, :destroy]
  before_action :grab_subscription
  before_action :grab_all

  load_and_authorize_resource

  # GET /tickets
  # GET /tickets.json
  def index
    @tickets = Ticket.all

    @properties = Property.all
    @pj = @properties.to_json(:only => [:id, :name])

    respond_to do |format|
        format.html
        format.json { render :json => @pj}
    end
  end

  # GET /tickets/1
  # GET /tickets/1.json
  def show
  end

  # GET /tickets/new
  def new
    @ticket = Ticket.new
  end

  # GET /tickets/1/edit
  def edit
  end

  # POST /tickets
  # POST /tickets.json
  def create
   	@ticket = Ticket.new(ticket_params)

    respond_to do |format|
        if @ticket.save
            format.html { redirect_to @ticket, notice: 'Ticket was successfully created.' }
            format.json { render :show, status: :created, location: @ticket }

            @ticket.properties.each do |property|
                @ticket_category = property.category.name
            end

            @property_array = []
            @ticket.properties.each do |property|
                @property_name = property.name
                @property_array.push(@property_name)
                #@property_name = property.name "," unless property == @ticket.properties.last
            end

            #attributes to be put in email for ticket
            @created_at = @ticket.created_at
            @event_severity = @ticket.event_severity.downcase
            @event_status = @ticket.event_status
            @event_category = @ticket.event_category
            @customers_affected = @ticket.customers_affected
            @heat_ticket_number = @ticket.heat_ticket_number
            @bridge_number = @ticket.bridge_number

            @people_for = @people.select {|user| user["categories"].include?(@ticket_category)}
            @numbers_for_sms = @people_for.map {|numbers| numbers["phone_number"]}
            @numbers_for_sms.each do |pn|
            #UserNotifier.send_signup_email(@sub_user.name, @property_name, @heat_ticket_number, @bridge_number, @customers_affected, @ticket_category, @event_category, @event_severity, @event_status, @created_at).deliver_now

                @twilio_client.account.messages.create(
                    :from => "+1#{Rails.application.secrets.twilio_phone_number}",
                    :to => "#{pn}",
                    :body => "Hello, ticket ##{@heat_ticket_number} for #{@property_array.join(", ")} has been created via ENS. Event severity has been classified as #{@event_severity}. Please check your email for details."
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
            format.html { redirect_to @ticket, notice: 'Ticket was successfully updated.' }
            format.json { render :show, status: :ok, location: @ticket }

            @ticket.properties.each do |property|
                @ticket_category = property.category.name
            end

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

  # DELETE /tickets/1
  # DELETE /tickets/1.json
def destroy
    @ticket.destroy
    respond_to do |format|

        format.html { redirect_to tickets_url, notice: 'Ticket was successfully destroyed.' }
        format.json { head :no_content }
        
        #cycle through categories
        @ticket.properties.each do |property|
            @ticket_category = property.category.name
        end    


        #if the category of the ticket is in the subscriber's array, do below:
        @people_for = @people.select {|user| user["categories"].include?(@ticket_category)}
        @numbers_for_sms = @people_for.map {|numbers| numbers["phone_number"]}
        @numbers_for_sms.each do |pn|
            @twilio_client.account.messages.create(
                :from => "+1#{Rails.application.secrets.twilio_phone_number}",
                :to => "#{pn}",
                :body => "Hello, ticket ##{@ticket.heat_ticket_number} has been closed via ENS. Please check your email for details."
            )
        end
    end
end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_ticket
      @ticket = Ticket.find(params[:id])
    end

    def grab_subscription
        @sub_user = Subscription.find_by_name(current_user.email)
    end

    def grab_all
        @all_users = Subscription.where.not(phone_number: '')
        @people = @all_users.includes(:categories).map { |user| user.slice(:phone_number, :name).merge(categories: user.categories.map(&:name))}
        @twilio_client = Twilio::REST::Client.new Rails.application.secrets.twilio_sid, Rails.application.secrets.twilio_token
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def ticket_params
      params.require(:ticket).permit(:event_status, :event_severity, :event_category, :problem_statement, :additional_notes, :bridge_number, :heat_ticket_number, :customers_affected, :property_ids => [])
    end

end
