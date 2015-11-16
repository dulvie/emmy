class TaxCodesController < ApplicationController
  respond_to :html, :json
  load_and_authorize_resource through: :current_organization

  before_filter :new_breadcrumbs, only: [:new, :create]
  before_filter :show_breadcrumbs, only: [:edit, :show, :update]

  # GET /tax_codes
  # GET /tax_codes.json
  def index
    @breadcrumbs = [[t(:tax_codes)]]
    @tax_codes = current_organization.tax_codes.order(:code)
    @tax_codes = @tax_codes.page(params[:page])
    @trans = current_organization.code_transactions
                 .where("code = 'tax'")
                 .order('created_at DESC').first
  end

  # GET /tax_codes/new
  def new
  end

  # GET /tax_codes/1
  def show
    @connections = current_organization.accounts.where('tax_code_id = ? ', params[:id])
    @connections = @connections.page(params[:page])
  end

  # GET /tax_code/1/edit
  def edit
  end

  # POST /tax_codes
  # POST /tax_codes.json
  def create
    @tax_code = TaxCode.new(tax_code_params)
    @tax_code.organization = current_organization
    respond_to do |format|
      if @tax_code.save
        format.html { redirect_to tax_codes_url, notice: 'tax code period was successfully created.' }
      else
        flash.now[:danger] = "#{t(:failed_to_create)} #{t(:tax_code)}"
        format.html { render action: 'new' }
      end
    end
  end

  # PATCH/PUT /tax_codes/1
  # PATCH/PUT /tax_codes/1.json
  def update
    respond_to do |format|
      if @tax_code.update(tax_code_params)
        format.html { redirect_to tax_codes_url, notice: 'tax code period was successfully updated.' }
      else
        flash.now[:danger] = "#{t(:failed_to_update)} #{t(:tax_code)}"
        format.html { render action: 'show' }
      end
    end
  end

  # DELETE /tax_codes/1
  # DELETE /tax_codes/1.json
  def destroy
    @tax_code.destroy
    respond_to do |format|
      format.html { redirect_to tax_codes_url, notice: 'tax code period was successfully deleted.' }
    end
  end

  def order_import
    init_order_import
  end

  def import
    file = params[:file_importer][:file]
    @code_trans = CodeTransaction.new
    @code_trans.directory = TaxCode::DIRECTORY
    @code_trans.file = file
    @code_trans.code = 'tax'
    @code_trans.run_type = params[:file_importer][:type]
    @code_trans.complete = 'false'
    @code_trans.accounting_plan_id = params[:file_importer][:accounting_plan]
    @code_trans.user = current_user
    @code_trans.organization = current_organization
    respond_to do |format|
      if TaxCode.validate_file(file) && @code_trans.save
        format.html { redirect_to tax_codes_url, notice: "#{t(:tax_codes)} #{t(:was_successfully_created)}" }
      else
        init_order_import
        flash.now[:danger] = "#{t(:failed_to_create)} #{t(:tax_codes)}"
        format.html { render 'order_import' }
      end
    end
  end

  private

  # Never trust parameters from the scary internet, only allow the white list through.
  def tax_code_params
    params.require(:tax_code).permit(TaxCode.accessible_attributes.to_a)
  end

  def new_breadcrumbs
    @breadcrumbs = [[t(:tax_codes), tax_codes_path], ["#{t(:new)} #{t(:tax_code)}"]]
  end

  def show_breadcrumbs
    @breadcrumbs = [[t(:tax_codes), tax_codes_path], [@tax_code.code.to_s + ' ' + @tax_code.text]]
  end

  def init_order_import
    @breadcrumbs = [[t(:tax_codes), tax_codes_path], ["#{t(:order)} #{t(:import)}"]]
    @accounting_plans = current_organization.accounting_plans
    if @accounting_plans.size == 0
      redirect_to helps_show_message_path(message: "#{I18n.t(:accounting_plan)} #{I18n.t(:missing)}")
    end
    @tax_codes = current_organization.tax_codes
    @file_importer = FileImporter.new(TaxCode::DIRECTORY, @tax_codes, @accounting_plans)
    @files = @file_importer.files(TaxCode::FILES)
  end
end
