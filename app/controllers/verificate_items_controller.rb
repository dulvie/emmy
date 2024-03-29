class VerificateItemsController < ApplicationController
  respond_to :html, :json
  load_and_authorize_resource :verificate, through: :current_organization
  load_and_authorize_resource :verificate_item, through: :current_organization

  before_action :new_breadcrumbs, only: [:new, :create, :edit, :update]
  before_action :show_breadcrumbs, only: [:show]

  # GET
  def index
    @breadcrumbs = [['Verificate item']]
  end

  # GET
  def new
    accounting_plan = current_organization.accounting_plans.find(@verificate.accounting_period.accounting_plan_id)
    @accounting_groups = accounting_plan.accounting_groups.active.order(:number)
    @accounts = accounting_plan.accounts.where('active = ?', 'true').order(:number)
    @result_units = current_organization.result_units
    @tax_codes = current_organization.tax_codes.vat_purchase_basis
  end

  # GET
  def show
  end

  # GET
  def edit
    accounting_plan = current_organization.accounting_plans.find(@verificate.accounting_period.accounting_plan_id)
    @accounting_groups = accounting_plan.accounting_groups.active.order(:number)
    @accounts = accounting_plan.accounts.where('active = ?', 'true').order(:number)
    @result_units = current_organization.result_units
    @tax_codes = current_organization.tax_codes.vat_purchase_basis
end

  # POST
  def create
    @verificate = current_organization.verificates.find(params[:verificate_id])
    @verificate_item = @verificate.verificate_items.build verificate_item_params
    @verificate_item.organization = current_organization
    @verificate_item.accounting_period = @verificate.accounting_period
    respond_to do |format|
      if @verificate_item.save
        format.html { redirect_to verificate_path(@verificate), notice: "#{t(:verificate_item)} #{t(:was_successfully_created)}" }
      else
        @result_units = current_organization.result_units
        @accounting_groups = current_organization.verificates.find(@verificate).accounting_period.accounting_plan.accounting_groups
        flash.now[:danger] = "#{t(:failed_to_create)} #{t(:verificate_item)}"
        format.html { render action: 'new' }
      end
    end
  end

  # PATCH/PUT
  def update
    respond_to do |format|
      if @verificate_item.update(verificate_item_params)
        format.html { redirect_to verificate_path(@verificate), notice: "#{t(:verificate_item)} #{t(:was_successfully_updated)}" }
      else
        flash.now[:danger] = "#{t(:failed_to_update)} #{t(:verificate_item)}"
        format.html { render action: 'edit' }
      end
    end
  end

  # DELETE
  def destroy
    @verificate_item.destroy
    respond_to do |format|
      format.html { redirect_to verificate_path(@verificate), notice:  "#{t(:verificate_item)} #{t(:was_successfully_deleted)}" }
    end
  end

  private

  # Never trust parameters from the scary internet, only allow the white list through.
  def verificate_item_params
    params.require(:verificate_item).permit(:account_id, :description, :debit, :credit, :result_unit_id, :tax_code_id)
  end

  def new_breadcrumbs
    @verificate.number ? bc = @verificate.number : bc = '*'
    @breadcrumbs = [[t(:verificates), verificates_path],
                    [bc, verificate_path(@verificate)],
                    ["#{t(:new)} #{t(:verificate_item)}"]]
  end

  def show_breadcrumbs
    @breadcrumbs = [[t(:verificates), verificates_path],
                    [@verificate.number, verificate_plan_path(@verificate)],
                    [@verificate_item.description]]
  end
end
