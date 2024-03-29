class ClosingBalanceItemsController < ApplicationController
  respond_to :html, :json
  load_and_authorize_resource :closing_balance, through: :current_organization
  load_and_authorize_resource :closing_balance_item, through: :closing_balance

  before_action :new_breadcrumbs, only: [:new, :create]
  before_action :show_breadcrumbs, only: [:edit, :show, :update]

  # GET
  def index
    @breadcrumbs = [['Closing balance items']]
  end

  # GET
  def new
    accounting_plan = current_organization.accounting_plans.find(@closing_balance.accounting_period.accounting_plan_id)
    @accounting_groups = accounting_plan.accounting_groups.order(:number)
    @accounts = accounting_plan.accounts.order(:number)
    gon.push accounting_groups: ActiveModel::ArraySerializer.new(@accounting_groups, each_serializer: AccountingGroupSerializer),
             accounts: ActiveModel::ArraySerializer.new(@accounts, each_serializer: AccountSerializer)
  end

  # GET
  def show
  end

  # GET
  def edit
  end

  # POST
  def create
    @closing_balance = current_organization.closing_balances.find(params[:closing_balance_id])
    @closing_balance_item = @closing_balance.closing_balance_items.build closing_balance_item_params
    @closing_balance_item.organization = current_organization
    @closing_balance.accounting_period = @closing_balance.accounting_period
    respond_to do |format|
      if @closing_balance_item.save
        format.html { redirect_to closing_balance_path(@closing_balance), notice: "#{t(:closing_balance_item)} #{t(:was_successfully_created)}" }
      else
        @accounting_groups = current_organization.accounting_plan.accounting_groups
        gon.push accounting_groups: ActiveModel::ArraySerializer.new(@accounting_groups, each_serializer: AccountingGroupSerializer)
        flash.now[:danger] = "#{t(:failed_to_create)} #{t(:closing_balance_item)}"
        format.html { render action: 'new' }
      end
    end
  end

  # PATCH/PUT
  def update
    respond_to do |format|
      if @closing_balance_item.update(closing_balance_item_params)
        format.html { redirect_to closing_balance_path(@closing_balance), notice: "#{t(:closing_balance_item)} #{t(:was_successfully_updated)}" }
      else
        flash.now[:danger] = "#{t(:failed_to_update)} #{t(:closing_balance_item)}"
        format.html { render action: 'show' }
      end
    end
  end

  # DELETE
  def destroy
    @closing_balance_item.destroy
    respond_to do |format|
      format.html { redirect_to closing_balance_path(@closing_balance), notice:  "#{t(:closing_balance_item)} #{t(:was_successfully_deleted)}" }
    end
  end

  private

  # Never trust parameters from the scary internet, only allow the white list through.
  def closing_balance_item_params
    params.require(:closing_balance_item).permit(:account_id, :description, :debit, :credit)
  end

  def new_breadcrumbs
    @breadcrumbs = [[t(:closing_balances), closing_balances_path],
                    [@closing_balance.description, closing_balance_path(@closing_balance)],
                    ["#{t(:new)} #{t(:closing_balance_item)}"]]
  end

  def show_breadcrumbs
    @breadcrumbs = [[t(:closing_balances), closing_balances_path],
                    [@closing_balance.number, closing_balance_plan_path(@closing_balance)],
                    [@closing_balance_item.description]]
  end
end
