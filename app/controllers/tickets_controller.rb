class TicketsController < ApplicationController
  before_action :set_ticket, only: [:show, :edit, :update, :destroy]

  # GET /tickets
  # GET /tickets.json
  def index
    @tickets = Ticket.all
  end

  # GET /tickets/1
  # GET /tickets/1.json
  def show
  end

  # GET /tickets/new
  def new
    @ticket = Ticket.new

    @sub_user = Subscription.find_by_name(current_user.email)

    # @sub_user.categories.each do |category|
    #     @sub_user_categories = category.name
    # end

    

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

            @sub_user = Subscription.find_by_name(current_user.email)

            @people = {
                "#{@sub_user.phone_number}" => "#{@sub_user.name}"                    
            }

            twilio_sid = "<%= ENV['TWILIO_SID'] %>"
            twilio_token = "<%= ENV['TWILIO_TOKEN'] %>"
            twilio_phone_number = "<%= ENV['TWILIO_PHONE_NUMBER'] %>"
            @twilio_client = Twilio::REST::Client.new twilio_sid, twilio_token

            @ticket.properties.each do |property|
                property.categories.each do |category|
                    @ticket_category = category.name
                end
            end

            @sub_cat_list = []
            @sub_user.categories.each do |category|
                @sub_cat_list << category.name
            end

            if @sub_cat_list.include?(@ticket_category)
                #send email
                @people.each do |key, value|
                    @twilio_client.account.sms.messages.create(
                        :from => "+1#{twilio_phone_number}",
                        :to => key,
                        :body => "Hello #{value}, a ticket in category #{@ticket_category} has been created for ENS. Please check your email for details."
                    )
                end
            else 
                #dont send email
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
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_ticket
      @ticket = Ticket.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def ticket_params
      params.require(:ticket).permit(:event_status, :customers_affected, :property_ids)
    end
end
