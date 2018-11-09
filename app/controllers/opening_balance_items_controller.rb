class OpeningBalanceItemsController < ApplicationController
  respond_to :html, :json
  load_and_authorize_resource :opening_balance, through: :current_organization
  load_and_authorize_resource :opening_balance_item, through: :current_organization

  before_action :new_breadcrumbs, only: [:new, :create]
  before_action :show_breadcrumbs, only: [:edit, :show, :update]

  # GET
  def index
    @breadcrumbs = [[t(:opening_balances), opening_balances_path], ['Opening balance items']]
    @opening_balance_items = @opening_balance_items.page(params[:page])
  end

  # GET
  def new
    accounting_plan = current_organization.accounting_plans.find(@opening_balance.accounting_period.accounting_plan_id)
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
    @opening_balance = current_organization.opening_balances.find(params[:opening_balance_id])
    @opening_balance_item = @opening_balance.opening_balance_items.build opening_balance_item_params
    @opening_balance_item.organization = current_organization
    @opening_balance_item.accounting_period = @opening_balance.accounting_period
    respond_to do |format|
      if @opening_balance_item.save
        format.html { redirect_to edit_accounting_period_path(@opening_balance.accounting_period_id), notice: "#{t(:opening_balance_item)} #{t(:was_successfully_created)}" }
      else
        @accounting_groups = current_organization.accounting_plan.accounting_groups
        gon.push accounting_groups: ActiveModel::ArraySerializer.new(@accounting_groups, each_serializer: AccountingGroupSerializer)
        flash.now[:danger] = "#{t(:failed_to_create)} #{t(:opening_balance_item)}"
        format.html { render action: 'new' }
      end
    end
  end

  # PATCH/PUT
  def update
    respond_to do |format|
      if @opening_balance_item.update(opening_balance_item_params)
        format.html { redirect_to opening_balance_path(@opening_balance), notice: "#{t(:opening_balance_item)} #{t(:was_successfully_updated)}" }
      else
        flash.now[:danger] = "#{t(:failed_to_update)} #{t(:opening_balance_item)}"
        format.html { render action: 'show' }
      end
    end
  end

  # DELETE
  def destroy
    @opening_balance_item.destroy
    respond_to do |format|
      format.html { redirect_to edit_accounting_period_path(@opening_balance.accounting_period_id), notice:  "#{t(:opening_balance_item)} #{t(:was_successfully_deleted)}" }
    end
  end

  private

  # Never trust parameters from the scary internet, only allow the white list through.
  def opening_balance_item_params
    params.require(:opening_balance_item).permit(:account_id, :description, :debit, :credit)
  end

  def new_breadcrumbs
    @breadcrumbs = [[t(:opening_balances), opening_balances_path],
                    [@opening_balance.description, opening_balance_path(@opening_balance)],
                    ["#{t(:new)} #{t(:opening_balance_item)}"]]
  end

  def show_breadcrumbs
    @breadcrumbs = [[t(:opening_balances), opening_balances_path],
                    [@opening_balance.number, opening_balance_plan_path(@opening_balance)],
                    [@opening_balance_item.description]]
  end
end
