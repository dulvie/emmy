class InkCodesController < ApplicationController
  respond_to :html, :json
  load_and_authorize_resource through: :current_organization

  before_filter :new_breadcrumbs, only: [:new, :create]
  before_filter :show_breadcrumbs, only: [:edit, :show, :update]

  # GET /ink_codes
  # GET /ink_codes.json
  def index
    @breadcrumbs = [[t(:ink_codes)]]
    @ink_codes = current_organization.ink_codes
    @ink_codes = @ink_codes.page(params[:page])
    @trans = current_organization.code_transactions.where("code = 'ink'").order("created_at DESC").first
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
    file = params[:file_importer][:file]
    @code_trans = CodeTransaction.new
    @code_trans.directory = InkCode::DIRECTORY
    @code_trans.file = file
    @code_trans.code = 'ink'
    @code_trans.run_type = params[:file_importer][:type]
    @code_trans.complete = 'false'
    @code_trans.accounting_plan_id = params[:file_importer][:accounting_plan]
    @code_trans.user = current_user
    @code_trans.organization = current_organization
    respond_to do |format|
      if InkCode.validate_file(file) && @code_trans.save
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
    @breadcrumbs = [[t(:ink_codes), ink_codes_path], ["#{t(:new)} #{t(:ink_code)}"]]
  end

  def show_breadcrumbs
    @breadcrumbs = [[t(:ink_codes), ink_codes_path], [@ink_code.code]]
  end

  def init_order_import
    @breadcrumbs = [[t(:ink_codes), ink_codes_path], ["#{t(:order)} #{t(:import)}"]]
    @ink_codes = current_organization.ink_codes
    @accounting_plans = current_organization.accounting_plans
    if @accounting_plans.size == 0
      redirect_to helps_show_message_path(message: "#{I18n.t(:accounting_plans)} #{I18n.t(:missing)}")
    end
    @file_importer = FileImporter.new(InkCode::DIRECTORY, @ink_codes, @accounting_plans)
    @files = @file_importer.files(InkCode::FILES)
  end
end
