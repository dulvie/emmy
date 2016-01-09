class AccountingPlansController < ApplicationController
  respond_to :html, :json
  load_and_authorize_resource through: :current_organization

  before_filter :new_breadcrumbs, only: [:new, :create]
  before_filter :show_breadcrumbs, only: [:edit, :show, :update]

  # GET /accounting_plans
  # GET /accounting_plans.json
  def index
    @breadcrumbs = [["#{t(:accounting_plans)}"]]
    init
  end

  # GET /accounting_plan/new
  def new
  end

  # GET /accounting_plan/1
  def show
    init_accounts
  end

  # GET /vat/1/edit
  def edit
  end

  # POST /accounting_plan
  # POST /accounting_plan.json
  def create
    @accounting_plan = AccountingPlan.new(accounting_plan_params)
    @accounting_plan.organization = current_organization
    respond_to do |format|
      if @accounting_plan.save
        format.html { redirect_to accounting_plans_url, notice: "#{t(:accounting_plan)} #{t(:was_successfully_created)}" }
      else
        flash.now[:danger] = "#{t(:failed_to_create)} #{t(:accounting_plan)}"
        format.html { render action: 'new' }
      end
    end
  end

  # PATCH/PUT /accounting_plan/1
  # PATCH/PUT /accounting_plan/1.json
  def update
    respond_to do |format|
      if @accounting_plan.update(accounting_plan_params)
        format.html { redirect_to accounting_plans_url, notice: "#{t(:accounting_plan)} #{t(:was_successfully_updated)}" }
      else
        flash.now[:danger] = "#{t(:failed_to_update)} #{t(:accounting_plan)}"
        format.html { render action: 'show' }
      end
    end
  end

  # DELETE /accounting_plan/1
  # DELETE /accounting_plan/1.json
  def destroy
    @accounting_plan.destroy
    respond_to do |format|
      format.html { redirect_to accounting_plans_url, notice: "#{t(:accounting_plan)} #{t(:was_successfully_deleted)}" }
    end
  end

  def order_import
    init_order_import
  end

  def import
    file = params[:file_importer][:file]
    @accounting_plan_trans = init_accounting_plan_trans
    @accounting_plan_trans.file = file
    @accounting_plan_trans.execute = 'import'
    @accounting_plan_trans.accounting_plan_id = nil
    respond_to do |format|
      if AccountingPlan.validate_file(file) && @accounting_plan_trans.save
        format.html { redirect_to accounting_plans_url, notice: "#{t(:accounting_plan)} #{t(:was_successfully_updated)}" }
      else
        init_order_import
        flash.now[:danger] = "#{t(:failed_to_create)} #{t(:accounting_plan)}"
        format.html { render 'order_import' }
      end
    end
  end

  def disable_accounts
    @accounting_plan_trans = init_accounting_plan_trans
    @accounting_plan_trans.file = 'Kontoplan_Normal_2014_ver1.csv'
    @accounting_plan_trans.execute = 'disable'
    @accounting_plan_trans.accounting_plan_id = params[:accounting_plan_id]
    respond_to do |format|
      if @accounting_plan_trans.save
        format.html { redirect_to accounting_plans_url, notice: "#{t(:accounting_plan)} #{t(:was_successfully_updated)}" }
      else
        init_order_import
        flash.now[:danger] = "#{t(:failed_to_create)} #{t(:accounting_plan)}"
        format.html { render 'order_import' }
      end
    end
  end

  private

  # Never trust parameters from the scary internet, only allow the white list through.
  def accounting_plan_params
    params.require(:accounting_plan).permit(AccountingPlan.accessible_attributes.to_a)
  end

  def new_breadcrumbs
    @breadcrumbs = [["#{t(:accounting_plan)}", accounting_plans_path], ["#{t(:new)} #{t(:accounting_plan)}"]]
  end

  def show_breadcrumbs
    @breadcrumbs = [["#{t(:accounting_plan)}", accounting_plans_path], [@accounting_plan.name]]
  end

  def init
    @accounting_plans = current_organization.accounting_plans.order(:name)
    @accounting_plans = @accounting_plans.page(params[:page]).decorate
  end

  def init_order_import
    @breadcrumbs = [["#{t(:accounting_plan)}", accounting_plans_path], ["#{t(:order)} #{t(:import)}"]]
    from_directory = AccountingPlan::DIRECTORY
    existing_plans = current_organization.accounting_plans.pluck(:file_name)
    @file_importer = FileImporter.new(from_directory, nil, nil)
    @file_importer.file_filter(existing_plans)
    @files = @file_importer.files(AccountingPlan::FILES)
  end

  def init_accounting_plan_trans
    @accounting_plan_trans = AccountingPlanTransaction.new
    @accounting_plan_trans.posting_date = DateTime.now
    @accounting_plan_trans.directory = AccountingPlan::DIRECTORY
    @accounting_plan_trans.user = current_user
    @accounting_plan_trans.organization = current_organization
    @accounting_plan_trans
  end

  def init_accounts
    account_number = params[:account_number]
    account_number = 0000 if account_number.blank?
    if params[:active] == 'active'
      @accounts = @accounting_plan.accounts.order('number')
                      .where('accounts.active = ? and accounts.number >= ?', 'true', account_number)
                      .page(params[:page_account]).decorate
    elsif params[:active] == 'inactive'
      @accounts = @accounting_plan.accounts.order('number')
                      .where('accounts.active = ? and accounts.number >= ?', 'false', account_number)
                      .page(params[:page_account]).decorate
    else
      @accounts = @accounting_plan.accounts.order('number')
                      .where('accounts.number >= ?', account_number)
                      .page(params[:page_account]).decorate
    end
  end
end