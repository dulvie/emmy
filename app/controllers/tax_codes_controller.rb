class TaxCodesController < ApplicationController
  respond_to :html, :json
  load_and_authorize_resource through: :current_organization

  before_filter :new_breadcrumbs, only: [:new, :create]
  before_filter :show_breadcrumbs, only: [:edit, :show, :update]

  # GET /tax_codes
  # GET /tax_codes.json
  def index
    @breadcrumbs = [['Tax codes']]
    @tax_codes = current_organization.tax_codes.order(:code)
    @tax_codes = @tax_codes.page(params[:page])
  end

  # GET /tax_codes/new
  def new
  end

  # GET /tax_codes/1
  def show
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
    directory = params[:file_importer][:directory]
    file_name = params[:file_importer][:file]
    type = params[:file_importer][:type]
    @accounting_plan = current_organization.accounting_plans.find(params[:file_importer][:accounting_plan])
    @tax_codes = current_organization.tax_codes
    tax_code_creator = Services::TaxCodeCreator.new(current_organization, current_user, @tax_codes, @accounting_plan)
    respond_to do |format|
      if tax_code_creator.execute(type, directory, file_name)
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
    @breadcrumbs = [['Tax codes', tax_codes_path], ["#{t(:new)} #{t(:tax_code)}"]]
  end

  def show_breadcrumbs
    @breadcrumbs = [['Tax codes', tax_codes_path], [@tax_code.code]]
  end

  def init_order_import
    @breadcrumbs = [["#{t(:tax_codes)}", tax_codes_path], ["#{t(:order)} #{t(:import)}"]]
    from_directory = "files/codes/"
    @tax_codes = current_organization.tax_codes
    @accounting_plans = current_organization.accounting_plans
    @file_importer = FileImporter.new(from_directory, @tax_codes, @accounting_plans)
    @files = @file_importer.files('TAX*.csv')
  end
end
