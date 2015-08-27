class DefaultCodesController < ApplicationController
  respond_to :html, :json
  load_and_authorize_resource through: :current_organization

  before_filter :new_breadcrumbs, only: [:new, :create]
  before_filter :show_breadcrumbs, only: [:edit, :show, :update]

  # GET /default__codes
  # GET /default_codes.json
  def index
    @breadcrumbs = [['Default codes']]
    @default_codes = @default_codes.page(params[:page])
    @trans = current_organization.code_transactions.where("code = 'default'").order("created_at DESC").first
  end

  # GET /default_codes/new
  def new
  end

  # GET /default_codes/1
  def show
    @connections = current_organization.accounts.where("default_code_id = ? ", params[:id])
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

  def order_import
    init_order_import
  end

  def import
    @code_trans = CodeTransaction.new
    @code_trans.directory = params[:file_importer][:directory]
    @code_trans.file = params[:file_importer][:file]
    @code_trans.code = 'default'
    @code_trans.run_type = params[:file_importer][:type]
    @code_trans.complete = 'false'
    @code_trans.accounting_plan_id = params[:file_importer][:accounting_plan]
    @code_trans.user = current_user
    @code_trans.organization = current_organization
    respond_to do |format|
      if @code_trans.save
        format.html { redirect_to default_codes_url, notice: "#{t(:default_codes)} #{t(:was_successfully_created)}" }
      else
        init_order_import
        flash.now[:danger] = "#{t(:failed_to_create)} #{t(:default_codes)}"
        format.html { render 'order_import' }
      end
    end
  end

  private

  # Never trust parameters from the scary internet, only allow the white list through.
  def default_code_params
    params.require(:default_code).permit(DefaultCode.accessible_attributes.to_a)
  end

  def new_breadcrumbs
    @breadcrumbs = [['Default codes', default_codes_path], ["#{t(:new)} #{t(:default_code)}"]]
  end

  def show_breadcrumbs
    @breadcrumbs = [['Default codes', default_codes_path], [@default_code.code.to_s + ' ' + @default_code.text]]
  end

  def init_order_import
    @breadcrumbs = [["#{t(:default_codes)}", default_codes_path], ["#{t(:order)} #{t(:import)}"]]
    from_directory = "files/codes/"
    @default_codes = current_organization.default_codes
    @accounting_plans = current_organization.accounting_plans
    @file_importer = FileImporter.new(from_directory, @default_codes, @accounting_plans)
    @files = @file_importer.files('Default*.csv')
  end
end
