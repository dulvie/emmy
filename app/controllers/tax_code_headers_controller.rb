class TaxCodeHeadersController < ApplicationController
  respond_to :html, :json
  load_and_authorize_resource through: :current_organization

  before_action :new_breadcrumbs, only: [:new, :create]
  before_action :show_breadcrumbs, only: [:edit, :show, :update]

  # GET /tax_code_headers
  # GET /tax_code_headers.json
  def index
  end

  # GET /tax_code_headers/new
  def new
    @tax_code_header.name = 'TAX CODES'
    init_form
  end

  # GET /tax_code_headers/1
  def show
    init_form
  end

  # GET /tax_code_header/1/edit
  def edit
    init_form
  end

  # POST /tax_code_headers
  # POST /tax_code_headers.json
  def create
    @tax_code_header = TaxCodeHeader.new(tax_code_header_params)
    @tax_code_header.organization = current_organization
    respond_to do |format|
      if @tax_code_header.save
        format.html { redirect_to tax_codes_url, notice: "#{t(:tax_code_header)} #{t(:was_successfully_created)}" }
      else
        flash.now[:danger] = "#{t(:failed_to_create)} #{t(:tax_code_header)}"
        init_form
        format.html { render action: 'new' }
      end
    end
  end

  # PATCH/PUT /tax_code_headers/1
  # PATCH/PUT /tax_code_headers/1.json
  def update
    respond_to do |format|
      if @dtax_code_header.update(tax_code_header_params)
        format.html { redirect_to tax_codes_url, notice:  "#{t(:tax_code_header)} #{t(:was_successfully_updated)}" }
      else
        flash.now[:danger] = "#{t(:failed_to_update)} #{t(:tax_code_header)}"
        init_form
        format.html { render action: 'show' }
      end
    end
  end

  # DELETE /tax_code_headers/1
  # DELETE /tax_code_headers/1.json
  def destroy
    @tax_code_header.destroy
    respond_to do |format|
      format.html { redirect_to tax_codes_url, notice: "#{t(:tax_code_header)} #{t(:was_successfully_deleted)}" }
    end
  end

  private
  # Never trust parameters from the scary internet, only allow the white list through.
  def tax_code_header_params
    params.require(:tax_code_header).permit(:name, :file_name, :run_type, :accounting_plan_id)
  end

  def new_breadcrumbs
    @breadcrumbs = [[t(:tax_codes), tax_codes_path], ["#{t(:new)} #{t(:tax_code_header)}"]]
  end

  def show_breadcrumbs
    @breadcrumbs = [[t(:tax_codes), tax_codes_path], [@tax_code_header.name]]
  end

  def init_form
    @accounting_plans = current_organization.accounting_plans
    if @accounting_plans.size == 0
      redirect_to helps_show_message_path(message: "#{I18n.t(:accounting_plan)} #{I18n.t(:missing)}")
    end
    @tax_codes = current_organization.tax_codes
    @file_importer = FileImporter.new(TaxCodeHeader::DIRECTORY, @tax_codes, @accounting_plans)
    @files = @file_importer.files(TaxCodeHeader::FILES)
  end
end
