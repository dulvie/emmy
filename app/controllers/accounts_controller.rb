class AccountsController < ApplicationController
  respond_to :html, :json
  load_and_authorize_resource :accounting_plan, through: :current_organization
  load_and_authorize_resource :account, through: :current_organization

  before_filter :new_breadcrumbs, only: [:new, :create]
  before_filter :show_breadcrumbs, only: [:edit, :show, :update]

  # GET
  def index
    @breadcrumbs = [['Accounts']]
  end

  # GET
  def new
    init
  end

  # GET
  def show
    init
  end

  # GET
  def edit
    init
  end

  # POST
  def create
    @accounting_plan = current_organization.accounting_plans.find(params[:accounting_plan_id])
    @account = @accounting_plan.accounts.build account_params
    @account.organization = current_organization
    respond_to do |format|
      if @account.save
        format.html { redirect_to accounting_plan_path(@accounting_plan), notice: "#{t(:account)} #{t(:was_successfully_created)}" }
      else
        init
        flash.now[:danger] = "#{t(:failed_to_create)} #{t(:account)}"
        format.html { render action: 'new' }
      end
    end
  end

  # PATCH/PUT
  def update
    respond_to do |format|
      if @account.update(account_params)
        format.html { redirect_to accounting_plan_path(@accounting_plan), notice: "#{t(:account)} #{t(:was_successfully_updated)}" }
      else
        init
        flash.now[:danger] = "#{t(:failed_to_update)} #{t(:account)}"
        format.html { render action: 'show' }
      end
    end
  end

  # DELETE
  def destroy
    @account.destroy
    respond_to do |format|
      format.html { redirect_to accounting_plan_path(@accounting_plan), notice: "#{t(:account)} #{t(:was_successfully_deleted)}" }
    end
  end

  def toggle_active
    @account = current_organization.accounts.find(params[:account_id])
    @account.toggle_active
    @account.save
    respond_to do |format|
      format.html { redirect_to :back }
    end
  end

  private

  # Never trust parameters from the scary internet, only allow the white list through.
  def account_params
    params.require(:account).permit(Account.accessible_attributes.to_a)
  end

  def new_breadcrumbs
    @breadcrumbs = [[t(:accounting_plans), accounting_plans_path],
                    [@accounting_plan.name, accounting_plan_path(@accounting_plan)],
                    ["#{t(:new)} #{t(:account)}"]]
  end

  def show_breadcrumbs
    @breadcrumbs = [[t(:accounting_plans), accounting_plans_path],
                    [@accounting_plan.name, accounting_plan_path(@accounting_plan)],
                    [@account.name]]
  end

  def init
    @tax_codes = current_organization.tax_codes
    @default_codes = current_organization.default_codes
    @ink_codes = current_organization.ink_codes
    @ne_codes = current_organization.ne_codes
  end
end
