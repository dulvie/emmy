class InkCodesController < ApplicationController
  respond_to :html, :json
  load_and_authorize_resource through: :current_organization

  before_filter :new_breadcrumbs, only: [:new, :create]
  before_filter :show_breadcrumbs, only: [:edit, :show, :update]

  # GET /ink_codes
  # GET /ink_codes.json
  def index
    @breadcrumbs = [['Ink codes']]
    @ink_codes = current_organization.ink_codes
    @ink_codes = @ink_codes.page(params[:page])
  end

  # GET /ink_codes/new
  def new
  end

  # GET /ink_codes/1
  def show
  end

  # GET /ink_code/1/edit
  def edit
  end

  # POST /ink_codes
  # POST /ink_codes.json
  def create
    @ink_code = InkCode.new(ink_code_params)
    @ink_code.organization = current_organization
    respond_to do |format|
      if @ink_code.save
        format.html { redirect_to ink_codes_url, notice: 'ink code period was successfully created.' }
      else
        flash.now[:danger] = "#{t(:failed_to_create)} #{t(:ink_code)}"
        format.html { render action: 'new' }
      end
    end
  end

  # PATCH/PUT /ink_codes/1
  # PATCH/PUT /ink_codes/1.json
  def update
    respond_to do |format|
      if @ink_code.update(ink_code_params)
        format.html { redirect_to ink_codes_url, notice: 'ink code period was successfully updated.' }
      else
        flash.now[:danger] = "#{t(:failed_to_update)} #{t(:ink_code)}"
        format.html { render action: 'show' }
      end
    end
  end

  # DELETE /ink_codes/1
  # DELETE /ink_codes/1.json
  def destroy
    @ink_code.destroy
    respond_to do |format|
      format.html { redirect_to ink_codes_url, notice: 'ink code period was successfully deleted.' }
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
    @ink_codes = current_organization.ink_codes
    ink_code_creator = Services::InkCodeCreator.new(current_organization, current_user, @ink_codes, @accounting_plan)
    respond_to do |format|
      if ink_code_creator.execute(type, directory, file_name)
        format.html { redirect_to ink_codes_url, notice: "#{t(:ink_codes)} #{t(:was_successfully_created)}" }
      else
        init_order_import
        flash.now[:danger] = "#{t(:failed_to_create)} #{t(:ink_codes)}"
        format.html { render 'order_import' }
      end
    end
  end
  private

  # Never trust parameters from the scary internet, only allow the white list through.
  def ink_code_params
    params.require(:ink_code).permit(InkCode.accessible_attributes.to_a)
  end

  def new_breadcrumbs
    @breadcrumbs = [['Ink codes', ink_codes_path], ["#{t(:new)} #{t(:ink_code)}"]]
  end

  def show_breadcrumbs
    @breadcrumbs = [['Ink codes', ink_codes_path], [@ink_code.code]]
  end

  def init_order_import
    @breadcrumbs = [["#{t(:ink_codes)}", ink_codes_path], ["#{t(:order)} #{t(:import)}"]]
    from_directory = "files/codes/"
    @file_importer = FileImporter.new(from_directory)
    @files = @file_importer.files('INK*.csv')
    @accounting_plans = current_organization.accounting_plans
    @ink_codes = current_organization.ink_codes
    @types = FileImporter::LOAD if @accounting_plans.size == 0 && @ink_codes.size == 0
    @types = FileImporter::LOAD_CONNECT if @accounting_plans.size > 0 && @ink_codes.size == 0
    @types = FileImporter::RELOAD if @accounting_plans.size == 0 && @ink_codes.size > 0
    @types = FileImporter::RELOAD_CONNECT if @accounting_plans.size > 0 && @ink_codes.size > 0
  end
end
