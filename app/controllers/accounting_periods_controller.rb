class AccountingPeriodsController < ApplicationController
  respond_to :html, :json
  load_and_authorize_resource through: :current_organization

  before_filter :new_breadcrumbs, only: [:new, :create]
  before_filter :show_breadcrumbs, only: [:edit, :show, :update]
  before_filter :load_dependence, only: [:new, :edit]

  # GET
  def index
    @breadcrumbs = [[t(:accounting_periods)]]
    @accounting_periods = current_organization.accounting_periods.order(:accounting_from)
    @accounting_periods = @accounting_periods.page(params[:page]).decorate
  end

  # GET
  def new
    @accounting_period.name = t(:accounting_period) + " " + (Date.current.year + 1).to_s
    @accounting_period.accounting_from = Date.new(Date.current.year+1, 1, 1)
    @accounting_period.accounting_to = Date.new(Date.current.year+1, 12, 31)
  end

  # GET
  def show
  end

  # GET
  def edit
    @opening_balance = init_opening_balance
    @closing_balance = init_closing_balance
    @previous_accounting_period = @accounting_period.previous_accounting_period
  end

  # POST
  def create
    @account_period = AccountingPeriod.new(accounting_period_params)
    @account_period.organization = current_organization
    respond_to do |format|
      if @accounting_period.save
        format.html { redirect_to accounting_periods_url, notice: "#{t(:accounting_period)} #{t(:was_successfully_created)}"}
      else
        @accounting_plans = current_organization.accounting_plans
        flash.now[:danger] = "#{t(:failed_to_create)} #{t(:accounting_period)}"
        format.html { render action: 'new' }
      end
    end
  end

  # PATCH/PUT
  def update
    respond_to do |format|
      if @accounting_period.update(accounting_period_params)
        format.html { redirect_to accounting_periods_url, notice: "#{t(:accounting_period)} #{t(:was_successfully_updated)}" }
      else
        @accounting_plans = current_organization.accounting_plans
        flash.now[:danger] = "#{t(:failed_to_update)} #{t(:accounting_period)}"
        format.html { render action: 'show' }
      end
    end
  end

  # DELETE
  def destroy
    @accounting_period.destroy
    respond_to do |format|
      format.html { redirect_to accounting_periods_url, notice: "#{t(:accounting_period)} #{t(:was_successfully_deleted)}"}
    end
  end

  def import_sie
    accounting_period = @accounting_period
    accounting_plan = current_organization.accounting_plans.find_by_name("BAS – Kontoplan 2014")
    @import_sie = Services::ImportSie.new(current_organization, current_user, accounting_period, accounting_plan)
    respond_to do |format|
      if @import_sie.read_and_save
        format.html { redirect_to accounting_periods_url, notice: "#{t(:accounting_period)} #{t(:was_successfully_created)}" }
      else
        flash.now[:danger] = "#{t(:failed_to_update)} #{t(:accounting_period)}"
        format.html { redirect_to accounting_periods_url }
      end
    end
  end

  private

  # Never trust parameters from the scary internet, only allow the white list through.
  def accounting_period_params
    params.require(:accounting_period).permit(AccountingPeriod.accessible_attributes.to_a)
  end

  def new_breadcrumbs
    @breadcrumbs = [[t(:accounting_periods), accounting_periods_path], ["#{t(:new)} #{t(:accounting_period)}"]]
  end

  def show_breadcrumbs
    @breadcrumbs = [[t(:accounting_periods), accounting_periods_path], [@accounting_period.name]]
  end

  def init_closing_balance
    return @accounting_period.closing_balance if !@accounting_period.closing_balance.nil?
    @closing_balance = ClosingBalance.new
    @closing_balance.description = 'UB ' + @accounting_period.accounting_from.strftime("%Y")
    return @closing_balance
  end

  def init_opening_balance
    return @accounting_period.opening_balance if !@accounting_period.opening_balance.nil?
    @opening_balance = OpeningBalance.new
    @opening_balance.description = 'IB ' + @accounting_period.accounting_from.strftime("%Y")
    return @opening_balance
  end

  def load_dependence
    @accounting_plans = current_organization.accounting_plans
    if @accounting_plans.size == 0
      redirect_to helps_show_message_path(message: "#{I18n.t(:accounting_plans)} #{I18n.t(:missing)}")
    end
  end
end
