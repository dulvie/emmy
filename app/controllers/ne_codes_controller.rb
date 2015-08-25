class NeCodesController < ApplicationController
  respond_to :html, :json
  load_and_authorize_resource through: :current_organization

  before_filter :new_breadcrumbs, only: [:new, :create]
  before_filter :show_breadcrumbs, only: [:edit, :show, :update]

  # GET /ne_codes
  # GET /ne_codes.json
  def index
    @breadcrumbs = [['Ne codes']]
    @ne_codes = current_organization.ne_codes
    @ne_codes = @ne_codes.page(params[:page])
  end

  # GET /ne_codes/new
  def new
  end

  # GET /ne_codes/1
  def show
  end

  # GET /ne_code/1/edit
  def edit
  end

  # POST /ne_codes
  # POST /ne_codes.json
  def create
    @ne_code = NeCode.new(ne_code_params)
    @ne_code.organization = current_organization
    respond_to do |format|
      if @ne_code.save
        format.html { redirect_to ne_codes_url, notice: 'ink code period was successfully created.' }
      else
        flash.now[:danger] = "#{t(:failed_to_create)} #{t(:ne_code)}"
        format.html { render action: 'new' }
      end
    end
  end

  # PATCH/PUT /ne_codes/1
  # PATCH/PUT /ne_codes/1.json
  def update
    respond_to do |format|
      if @ne_code.update(ne_code_params)
        format.html { redirect_to ne_codes_url, notice: 'ink code period was successfully updated.' }
      else
        flash.now[:danger] = "#{t(:failed_to_update)} #{t(:ne_code)}"
        format.html { render action: 'show' }
      end
    end
  end

  # DELETE /ne_codes/1
  # DELETE /ne_codes/1.json
  def destroy
    @ne_code.destroy
    respond_to do |format|
      format.html { redirect_to ne_codes_url, notice: 'ink code period was successfully deleted.' }
    end
  end

  def order_import
    init_order_import
  end

  def import
    @code_trans = CodeTransaction.new
    @code_trans.directory = params[:file_importer][:directory]
    @code_trans.file = params[:file_importer][:file]
    @code_trans.code = 'ne'
    @code_trans.run_type = params[:file_importer][:type]
    @code_trans.accounting_plan_id = params[:file_importer][:accounting_plan]
    @code_trans.user = current_user
    @code_trans.organization = current_organization
    respond_to do |format|
      if @code_trans.save
        format.html { redirect_to ne_codes_url, notice: "#{t(:ne_codes)} #{t(:was_successfully_created)}" }
      else
        init_order_import
        flash.now[:danger] = "#{t(:failed_to_create)} #{t(:ne_codes)}"
        format.html { render 'order_import' }
      end
    end
  end

  private

  # Never trust parameters from the scary internet, only allow the white list through.
  def ne_code_params
    params.require(:ne_code).permit(NeCode.accessible_attributes.to_a)
  end

  def new_breadcrumbs
    @breadcrumbs = [['Ne codes', ne_codes_path], ["#{t(:new)} #{t(:ne_code)}"]]
  end

  def show_breadcrumbs
    @breadcrumbs = [['Ne codes', ne_codes_path], [@ne_code.code]]
  end

  def init_order_import
    @breadcrumbs = [["#{t(:ne_codes)}", ne_codes_path], ["#{t(:order)} #{t(:import)}"]]
    from_directory = "files/codes/"
    @ne_codes = current_organization.ne_codes
    @accounting_plans = current_organization.accounting_plans
    @file_importer = FileImporter.new(from_directory, @ne_codes, @accounting_plans)
    @files = @file_importer.files('NE*.csv')
  end
end
