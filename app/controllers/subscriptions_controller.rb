class SubscriptionsController < ApplicationController
  before_action :set_subscription, only: [:show, :edit, :update, :destroy]
  before_action :grab_subscription
  before_action :if_subscription_exists, only: [:new]
  load_and_authorize_resource
  
  # GET /subscriptions
  # GET /subscriptions.json
  def index
    @subscriptions = Subscription.all

    #authorize! :admin, @subscriptions
  end

  # GET /subscriptions/1
  # GET /subscriptions/1.json
  def show
  end

  # GET /subscriptions/new
  def new
    @subscription = Subscription.new
  end

  def carrier_and_enterprise_locs
  end

  # GET /subscriptions/1/edit
  def edit
    #@current_sub_user = Subscription.find_by_name(current_user.email)
  end

  # POST /subscriptions
  # POST /subscriptions.json
  def create
    @subscription = Subscription.new(subscription_params)

    respond_to do |format|
      if @subscription.save
        UserNotifier.send_subscription_created_email(@subscription.name).deliver_now
        format.html { redirect_to tickets_path, notice: 'Subscription was successfully created.' }
        format.json { render :show, status: :created, location: @subscription }
      else
        format.html { render :new }
        format.json { render json: @subscription.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /subscriptions/1
  # PATCH/PUT /subscriptions/1.json
  def update
    respond_to do |format|
      if @subscription.update(subscription_params)
        format.html { redirect_to tickets_url, notice: 'Subscription was successfully updated.' }
        format.json { render :show, status: :ok, location: @subscription }
      else
        format.html { render :edit }
        format.json { render json: @subscription.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /subscriptions/1
  # DELETE /subscriptions/1.json
  def destroy
    @subscription.destroy
    respond_to do |format|
      format.html { redirect_to subscriptions_url, notice: 'Subscription was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.

    def if_subscription_exists
      @subscription = Subscription.find_by_name(current_user.email)
      if !@subscription.nil?
          redirect_to root_url, alert: 'You already have an existing subscription.'
      end
    end
    def set_subscription
      @subscription = Subscription.find(params[:id])
      rescue ActiveRecord::RecordNotFound
        redirect_to tickets_path, :alert => "You cannot access that subscription."
    end

    def grab_subscription
        @sub_user = Subscription.find_by_name(current_user.email)
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def subscription_params
      params.require(:subscription).permit(:name, :user_id, :phone_number, :category_ids => [])
    end
end
