class DefaultCodeHeadersController < ApplicationController
  respond_to :html, :json
  load_and_authorize_resource through: :current_organization

  before_action :new_breadcrumbs, only: [:new, :create]
  before_action :show_breadcrumbs, only: [:edit, :show, :update]

  # GET /default__codes
  # GET /default_codes.json
  def index
  end

  # GET /default_codes/new
  def new
    @default_code_header.name = 'Default CODES'
    init_form
  end

  # GET /default_codes/1
  def show
    init_form
  end

  # GET /default_code/1/edit
  def edit
    init_form
  end

  # POST /default_codes
  # POST /default_codes.json
  def create
    @default_code_header = DefaultCodeHeader.new(default_code_header_params)
    @default_code_header.organization = current_organization
    respond_to do |format|
      if @default_code_header.save
        format.html { redirect_to default_codes_url, notice: "#{t(:default_code_header)} #{t(:was_successfully_created)}" }
      else
        flash.now[:danger] = "#{t(:failed_to_create)} #{t(:default_code_header)}"
        init_form
        format.html { render action: 'new' }
      end
    end
  end

  # PATCH/PUT /default_codes/1
  # PATCH/PUT /default_codes/1.json
  def update
    respond_to do |format|
      if @default_code_header.update(default_code_header_params)
        format.html { redirect_to default_codes_url, notice:  "#{t(:default_code_header)} #{t(:was_successfully_updated)}" }
      else
        flash.now[:danger] = "#{t(:failed_to_update)} #{t(:default_code_header)}"
        init_form
        format.html { render action: 'show' }
      end
    end
  end

  # DELETE /default_codes/1
  # DELETE /default_codes/1.json
  def destroy
    @default_code_header.destroy
    respond_to do |format|
      format.html { redirect_to default_codes_url, notice: "#{t(:default_code_header)} #{t(:was_successfully_deleted)}" }
    end
  end

  private
  # Never trust parameters from the scary internet, only allow the white list through.
  def default_code_header_params
    params.require(:default_code_header).permit(:name, :file_name, :run_type, :accounting_plan_id)
  end

  def new_breadcrumbs
    @breadcrumbs = [[t(:default_codes), default_codes_path], ["#{t(:new)} #{t(:default_code_header)}"]]
  end

  def show_breadcrumbs
    @breadcrumbs = [[t(:default_codes), default_codes_path], [@default_code_header.name]]
  end

  def init_form
    @accounting_plans = current_organization.accounting_plans
    if @accounting_plans.size == 0
      redirect_to helps_show_message_path(message: "#{I18n.t(:accounting_plan)} #{I18n.t(:missing)}")
    end
    @default_codes = current_organization.default_codes
    @file_importer = FileImporter.new(DefaultCodeHeader::DIRECTORY, @default_codes, @accounting_plans)
    @files = @file_importer.files(DefaultCodeHeader::FILES)
  end
end
