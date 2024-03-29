class ClosingBalancesController < ApplicationController
  respond_to :html, :json
  load_and_authorize_resource through: :current_organization

  before_action :new_breadcrumbs, only: [:new, :create]
  before_action :show_breadcrumbs, only: [:edit, :show, :update]

  # GET
  def index
    @breadcrumbs = [[t(:closing_balances)]]
    @closing_balances = current_organization.closing_balances
    @closing_balances = @closing_balances.page(params[:page]).decorate
  end

  # GET
  def new
    # @accounting_periods = current_organization.accounting_periods.where('active = ?', true)
    # gon.push accounting_periods: ActiveModel::ArraySerializer.new(@accounting_periods, each_serializer: AccountingPeriodSerializer)
  end

  # GET
  def show
    # @accounting_periods = current_organization.accounting_periods.where('active = ?', true)
    # gon.push accounting_periods: ActiveModel::ArraySerializer.new(@accounting_periods, each_serializer: AccountingPeriodSerializer)
  end

  # GET
  def edit
  end

  # POST
  def create
    @closing_balance = ClosingBalance.new(closing_balance_params)
    @closing_balance.organization = current_organization
    respond_to do |format|
      if @closing_balance.save
        format.html { redirect_to edit_accounting_period_path(@closing_balance.accounting_period_id), notice: "#{t(:closing_balance)} #{t(:was_successfully_created)}" }
      else
        format.html { redirect_to edit_accounting_period_path(@closing_balance.accounting_period_id), notice: "#{t(:failed_to_create)} #{t(:closing_balance)}" }
      end
    end
  end

  # PATCH/PUT
  def update
    respond_to do |format|
      if @closing_balance.update(closing_balance_params)
        format.html { redirect_to edit_accounting_period_path(@closing_balance.accounting_period), notice: "#{t(:closing_balance)} #{t(:was_successfully_created)}" }
      else
        flash.now[:danger] = "#{t(:failed_to_update)} #{t(:closing_balance)}"
        format.html { render action: 'show' }
      end
    end
  end

  # DELETE
  def destroy
    @closing_balance.destroy
    respond_to do |format|
      format.html { redirect_to closing_balances_path, notice:  "#{t(:closing_balance)} #{t(:was_successfully_deleted)}" }
    end
  end

  def state_change
    # X authorize! :manage, @verificate
    if @closing_balance.state_change(params[:event], params[:state_change_at])
      msg_h = { notice: t(:success) }
    else
      msg_h = { alert: t(:fail) }
    end
    redirect_to edit_accounting_period_path(@closing_balance.accounting_period), msg_h
  end

  private

  # Never trust parameters from the scary internet, only allow the white list through.
  def closing_balance_params
    params.require(:closing_balance).permit(:description, :accounting_period_id)
  end

  def new_breadcrumbs
    @breadcrumbs = [[t(:closing_balances), closing_balances_path], ["#{t(:new)} #{t(:closing_balance)}"]]
  end

  def show_breadcrumbs
    @breadcrumbs = [[t(:closing_balances), closing_balances_path], [@closing_balance.description]]
  end
end
