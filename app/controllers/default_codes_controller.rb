class DefaultCodesController < ApplicationController
  respond_to :html, :json
  load_and_authorize_resource through: :current_organization

  before_filter :new_breadcrumbs, only: [:new, :create]
  before_filter :show_breadcrumbs, only: [:edit, :show, :update]

  # GET /default__codes
  # GET /default_codes.json
  def index
    @breadcrumbs = [[t(:default_codes)]]
    @default_codes = @default_codes.page(params[:page])
    @default_code_header = current_organization.default_code_headers
                 .order('created_at DESC').first
  end

  # GET /default_codes/new
  def new
  end

  # GET /default_codes/1
  def show
    @connections = current_organization.accounts.where('default_code_id = ? ', params[:id])
    @connections = @connections.page(params[:page])
  end

  # GET /default_code/1/edit
  def edit
  end

  # POST /default_codes
  # POST /default_codes.json
  def create
    @default_code = DefaultCode.new(default_code_params)
    @default_code.organization = current_organization
    respond_to do |format|
      if @default_code.save
        format.html { redirect_to default_codes_url, notice: 'default code period was successfully created.' }
      else
        flash.now[:danger] = "#{t(:failed_to_create)} #{t(:default_code)}"
        format.html { render action: 'new' }
      end
    end
  end

  # PATCH/PUT /default_codes/1
  # PATCH/PUT /default_codes/1.json
  def update
    respond_to do |format|
      if @default_code.update(default_code_params)
        format.html { redirect_to default_codes_url, notice: 'default code period was successfully updated.' }
      else
        flash.now[:danger] = "#{t(:failed_to_update)} #{t(:default_code)}"
        format.html { render action: 'show' }
      end
    end
  end

  # DELETE /default_codes/1
  # DELETE /default_codes/1.json
  def destroy
    @default_code.destroy
    respond_to do |format|
      format.html { redirect_to default_codes_url, notice: 'default code period was successfully deleted.' }
    end
  end

  private

  # Never trust parameters from the scary internet, only allow the white list through.
  def default_code_params
    params.require(:default_code).permit(DefaultCode.accessible_attributes.to_a)
  end

  def new_breadcrumbs
    @breadcrumbs = [[t(:default_codes), default_codes_path], ["#{t(:new)} #{t(:default_code)}"]]
  end

  def show_breadcrumbs
    @breadcrumbs = [[t(:default_codes), default_codes_path], [@default_code.code.to_s + ' ' + @default_code.text]]
  end

  def init_order_import
    @breadcrumbs = [[t(:default_codes), default_codes_path], ["#{t(:order)} #{t(:import)}"]]
    @default_codes = current_organization.default_codes
    @accounting_plans = current_organization.accounting_plans
    if @accounting_plans.size == 0
      redirect_to helps_show_message_path(message: "#{I18n.t(:accounting_plan)} #{I18n.t(:missing)}")
    end
    @file_importer = FileImporter.new(DefaultCode::DIRECTORY, @default_codes, @accounting_plans)
    @files = @file_importer.files(DefaultCode::FILES)
  end
end
