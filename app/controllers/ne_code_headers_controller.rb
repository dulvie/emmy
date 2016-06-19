class NeCodeHeadersController < ApplicationController
  respond_to :html, :json
  load_and_authorize_resource through: :current_organization

  before_filter :new_breadcrumbs, only: [:new, :create]
  before_filter :show_breadcrumbs, only: [:edit, :show, :update]

  # GET /ne_code_headers
  # GET /ne_code_headers.json
  def index
  end

  # GET /ne_code_headers/new
  def new
    @ne_code_header.name = 'NE CODES'
    init_form
  end

  # GET /ne_code_headers/1
  def show
    init_form
  end

  # GET /ne_code_header/1/edit
  def edit
    init_form
  end

  # POST /ne_code_headers
  # POST /ne_code_headers.json
  def create
    @ne_code_header = NeCodeHeader.new(ne_code_header_params)
    @ne_code_header.organization = current_organization
    respond_to do |format|
      if @ne_code_header.save
        format.html { redirect_to ne_codes_url, notice: "#{t(:ne_code_header)} #{t(:was_successfully_created)}" }
      else
        flash.now[:danger] = "#{t(:failed_to_create)} #{t(:ne_code_header)}"
        init_form
        format.html { render action: 'new' }
      end
    end
  end

  # PATCH/PUT /ne_code_headers/1
  # PATCH/PUT /ne_code_headers/1.json
  def update
    respond_to do |format|
      if @dne_code_header.update(ne_code_header_params)
        format.html { redirect_to ne_codes_url, notice:  "#{t(:ne_code_header)} #{t(:was_successfully_updated)}" }
      else
        flash.now[:danger] = "#{t(:failed_to_update)} #{t(:ne_code_header)}"
        init_form
        format.html { render action: 'show' }
      end
    end
  end

  # DELETE /ne_code_headers/1
  # DELETE /ne_code_headers/1.json
  def destroy
    @ne_code_header.destroy
    respond_to do |format|
      format.html { redirect_to ne_codes_url, notice: "#{t(:ne_code_header)} #{t(:was_successfully_deleted)}" }
    end
  end

  private
  # Never trust parameters from the scary internet, only allow the white list through.
  def ne_code_header_params
    params.require(:ne_code_header).permit(NeCodeHeader.accessible_attributes.to_a)
  end

  def new_breadcrumbs
    @breadcrumbs = [[t(:ne_codes), ne_codes_path], ["#{t(:new)} #{t(:ne_code_header)}"]]
  end

  def show_breadcrumbs
    @breadcrumbs = [[t(:ne_codes), ne_codes_path], [@ne_code_header.name]]
  end

  def init_form
    @accounting_plans = current_organization.accounting_plans
    if @accounting_plans.size == 0
      redirect_to helps_show_message_path(message: "#{I18n.t(:accounting_plan)} #{I18n.t(:missing)}")
    end
    @ne_codes = current_organization.ne_codes
    @file_importer = FileImporter.new(NeCodeHeader::DIRECTORY, @ne_codes, @accounting_plans)
    @files = @file_importer.files(NeCodeHeader::FILES)
  end
end
