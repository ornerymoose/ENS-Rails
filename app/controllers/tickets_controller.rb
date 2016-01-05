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

            @people_for = @people.select {|user| user["categories"].include?(@ticket_category)}
            @numbers_for_sms = @people_for.map {|numbers| numbers["phone_number"]}
            @numbers_for_sms.each do |pn|
                UserNotifier.ticket_created(@sub_user.name, @property_array, @ticket.heat_ticket_number, @ticket.bridge_number, @ticket.customers_affected, @ticket_category, @ticket.event_category, @ticket.event_severity.downcase, @ticket.event_status, @ticket.created_at, @ticket.problem_statement, @ticket.additional_notes).deliver_now

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

            @people_for = @people.select {|user| user["categories"].include?(@ticket_category)}
            @numbers_for_sms = @people_for.map {|numbers| numbers["phone_number"]}
            @numbers_for_sms.each do |pn|
                UserNotifier.ticket_updated(@sub_user.name, @property_array, @ticket.heat_ticket_number, @ticket.bridge_number, @ticket.customers_affected, @ticket_category, @ticket.event_category, @ticket.event_severity, @ticket.event_status, @ticket.created_at, @ticket.problem_statement, @ticket.additional_notes).deliver_now
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

        @property_array = []
        @ticket.properties.each do |property|
            @property_name = property.name
            @property_array.push(@property_name)
        end    

        #if the category of the ticket is in the subscriber's array, do below:
        @people_for = @people.select {|user| user["categories"].include?(@ticket_category)}
        @numbers_for_sms = @people_for.map {|numbers| numbers["phone_number"]}
        @numbers_for_sms.each do |pn|
          UserNotifier.ticket_closed(@sub_user.name, @property_array, @ticket.heat_ticket_number, @ticket.bridge_number, @ticket.customers_affected, @ticket_category, @ticket.event_category, @ticket.event_severity, @ticket.event_status, @ticket.created_at, @ticket.problem_statement, @ticket.additional_notes).deliver_now
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
