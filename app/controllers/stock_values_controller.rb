class StockValuesController < ApplicationController
  respond_to :html, :json
  load_and_authorize_resource through: :current_organization

  before_action :new_breadcrumbs, only: [:new, :create]
  before_action :show_breadcrumbs, only: [:edit, :show, :update]

  # GET
  def index
    @breadcrumbs = [[t(:stock_values)]]
    @stock_values = @stock_values.page(params[:page]).decorate
  end

  # GET
  def new
  end

  # GET
  def show
  end

  # GET
  def edit
  end

  # POST
  def create
    @stock_value = StockValue.new(stock_value_params)
    @stock_value.organization = current_organization
    respond_to do |format|
      if @stock_value.save
        @stock_value_creator = Services::StockValueCreator.new(current_organization, current_user, @stock_value)
        @stock_value_creator.create_stock_value_items
        format.html { redirect_to stock_values_path, notice: "#{t(:stock_value)} #{t(:was_successfully_created)}" }
      else
        flash.now[:danger] = "#{t(:failed_to_create)} #{t(:stock_value)}"
        format.html { render action: 'new' }
      end
    end
  end

  # PATCH/PUT
  def update
    respond_to do |format|
      if @stock_value.update(stock_value_params)
        format.html { redirect_to stock_values_path, notice: "#{t(:stock_value)} #{t(:was_successfully_updated)}" }
      else
        flash.now[:danger] = "#{t(:failed_to_update)} #{t(:stock_value)}"
        format.html { render action: 'show' }
      end
    end
  end

  # DELETE
  def destroy
    @stock_value.destroy
    respond_to do |format|
      format.html { redirect_to stock_values_path, notice:  "#{t(:stock_value)} #{t(:was_successfully_deleted)}" }
    end
  end

  def state_change
    @stock_value = current_organization.stock_values.find(params[:id])
    authorize! :manage, @stock_value
    if @stock_value.state_change(params[:event], DateTime.now, current_user.id)
      msg_h = { notice: t(:success) }
    else
      msg_h = { alert: t(:fail) }
    end
    redirect_to stock_values_path, msg_h
  end

  private

  # Never trust parameters from the scary internet, only allow the white list through.
  def stock_value_params
    params.require(:stock_value).permit(:name, :comment, :value_date, :value)
  end

  def new_breadcrumbs
    @breadcrumbs = [[t(:stock_values), stock_values_path], ["#{t(:new)} #{t(:stock_value)}"]]
  end

  def show_breadcrumbs
    @breadcrumbs = [[t(:stock_values), stock_values_path], [@stock_value.name]]
  end
end
