class InkCodeHeadersController < ApplicationController
  respond_to :html, :json
  load_and_authorize_resource through: :current_organization

  before_action :new_breadcrumbs, only: [:new, :create]
  before_action :show_breadcrumbs, only: [:edit, :show, :update]

  # GET /ink_code_headers
  # GET /ink_code_headers.json
  def index
  end

  # GET /ink_code_headers/new
  def new
    @ink_code_header.name = 'INK CODES'
    init_form
  end

  # GET /ink_code_headers/1
  def show
    init_form
  end

  # GET /ink_code_header/1/edit
  def edit
    init_form
  end

  # POST /ink_code_headers
  # POST /ink_code_headers.json
  def create
    @ink_code_header = InkCodeHeader.new(ink_code_header_params)
    @ink_code_header.organization = current_organization
    respond_to do |format|
      if @ink_code_header.save
        format.html { redirect_to ink_codes_url, notice: "#{t(:ink_code_header)} #{t(:was_successfully_created)}" }
      else
        flash.now[:danger] = "#{t(:failed_to_create)} #{t(:ink_code_header)}"
        init_form
        format.html { render action: 'new' }
      end
    end
  end

  # PATCH/PUT /ink_code_headers/1
  # PATCH/PUT /ink_code_headers/1.json
  def update
    respond_to do |format|
      if @dink_code_header.update(ink_code_header_params)
        format.html { redirect_to ink_codes_url, notice:  "#{t(:ink_code_header)} #{t(:was_successfully_updated)}" }
      else
        flash.now[:danger] = "#{t(:failed_to_update)} #{t(:ink_code_header)}"
        init_form
        format.html { render action: 'show' }
      end
    end
  end

  # DELETE /ink_code_headers/1
  # DELETE /ink_code_headers/1.json
  def destroy
    @ink_code_header.destroy
    respond_to do |format|
      format.html { redirect_to ink_codes_url, notice: "#{t(:ink_code_header)} #{t(:was_successfully_deleted)}" }
    end
  end

  private
  # Never trust parameters from the scary internet, only allow the white list through.
  def ink_code_header_params
    params.require(:ink_code_header).permit(:name, :file_name, :run_type, :accounting_plan_id)
  end

  def new_breadcrumbs
    @breadcrumbs = [[t(:ink_codes), ink_codes_path], ["#{t(:new)} #{t(:ink_code_header)}"]]
  end

  def show_breadcrumbs
    @breadcrumbs = [[t(:ink_codes), ink_codes_path], [@ink_code_header.name]]
  end

  def init_form
    @accounting_plans = current_organization.accounting_plans
    if @accounting_plans.size == 0
      redirect_to helps_show_message_path(message: "#{I18n.t(:accounting_plan)} #{I18n.t(:missing)}")
    end
    @ink_codes = current_organization.ink_codes
    @file_importer = FileImporter.new(InkCodeHeader::DIRECTORY, @ink_codes, @accounting_plans)
    @files = @file_importer.files(InkCodeHeader::FILES)
  end
end
