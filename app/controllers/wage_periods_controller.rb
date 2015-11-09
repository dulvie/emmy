class WagePeriodsController < ApplicationController
  respond_to :html, :json
  load_and_authorize_resource through: :current_organization

  before_filter :new_breadcrumbs, only: [:new, :create]
  before_filter :show_breadcrumbs, only: [:edit, :show, :update]
  before_filter :load_accounting_periods, only: [:index]

  # GET /wage_periods
  # GET /wage_periods.json
  def index
    @breadcrumbs = [[t(:wage_periods)]]
    if params[:accounting_period_id]
      session[:accounting_period_id] = params[:accounting_period_id]
      @period = params[:accounting_period_id]
    elsif session[:accounting_period_id]
      @period = session[:accounting_period_id]
    else
      @period = @accounting_periods.last.id
      session[:accounting_period_id] = @period
    end
    @wage_periods = current_organization.wage_periods.where('accounting_period_id=?', @period).order(:wage_from)
    @wage_periods = @wage_periods.page(params[:page]).decorate
  end

  # GET /wage_periods/new
  def new
    @accounting_period = current_organization.accounting_periods.find(session[:accounting_period_id])
    @wage_period = @accounting_period.next_wage_period
    @suppliers = current_organization.suppliers.where('supplier_type = ?', 'RSV')
  end

  # GET /wage_periods/1
  def show
    @suppliers = current_organization.suppliers.where('supplier_type = ?', 'RSV')
  end

  # GET /wage/1/edit
  def edit
    @suppliers = current_organization.suppliers.where('supplier_type = ?', 'RSV')
  end

  # POST /wage_periods
  # POST /wage_periods.json
  def create
    @wage_period = WagePeriod.new(wage_period_params)
    @wage_period.organization = current_organization
    respond_to do |format|
      if @wage_period.save
        format.html { redirect_to wage_periods_url, notice: "#{t(:wage_period)} #{t(:was_successfully_created)}" }
      else
        @suppliers = current_organization.suppliers.where('supplier_type = ?', 'RSV')
        flash.now[:danger] = "#{t(:failed_to_create)} #{t(:wage_period)}"
        format.html { render action: 'new' }
      end
    end
  end

  # PATCH/PUT /wage_periods/1
  # PATCH/PUT /wage_periods/1.json
  def update
    respond_to do |format|
      if @wage_period.update(wage_period_params)
        format.html { redirect_to wage_periods_url, notice: "#{t(:wage_period)} #{t(:was_successfully_updated)}" }
      else
        @suppliers = current_organization.suppliers.where('supplier_type = ?', 'RSV')
        flash.now[:danger] = "#{t(:failed_to_update)} #{t(:wage_period)}"
        format.html { render action: 'edit' }
      end
    end
  end

  # DELETE /wage_periods/1
  # DELETE /wage_periods/1.json
  def destroy
    @wage_period.destroy
    respond_to do |format|
      format.html { redirect_to wage_periods_url, notice: "#{t(:wage_period)} #{t(:was_successfully_deleted)}"}
    end
  end

  def state_change
    @wage_period = current_organization.wage_periods.find(params[:id])
    authorize! :manage, @wage_period
    if @wage_period.state_change(params[:event], DateTime.now, current_user.id)
      msg_h = { notice: t(:success) }
    else
      msg_h = { alert: t(:fail) }
    end
     redirect_to wage_periods_path, msg_h
  end

  private

  # Never trust parameters from the scary internet, only allow the white list through.
  def wage_period_params
    params.require(:wage_period).permit(WagePeriod.accessible_attributes.to_a)
  end

  def new_breadcrumbs
    @breadcrumbs = [[t(:wage_periods), wage_periods_path], ["#{t(:new)} #{t(:wage_period)}"]]
  end

  def show_breadcrumbs
    @breadcrumbs = [[t(:wage_periods), wage_periods_path], [@wage_period.name]]
  end

  def load_accounting_periods
    @accounting_periods = current_organization.accounting_periods.order('id')
    if @accounting_periods.size == 0
      redirect_to helps_show_message_path(message: "#{I18n.t(:accounting_period)} #{I18n.t(:missing)}")
    end
  end
end
