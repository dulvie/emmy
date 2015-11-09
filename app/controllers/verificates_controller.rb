class VerificatesController < ApplicationController
  respond_to :html, :json
  #load_and_authorize_resource :accounting_period, through: :current_organization
  #load_and_authorize_resource :verificate, through: :accounting_period
  load_and_authorize_resource through: :current_organization

  before_filter :new_breadcrumbs, only: [:new, :create]
  before_filter :show_breadcrumbs, only: [:edit, :show, :update]
  before_filter :load_accounting_periods, only: [:index]

  # GET
  def index
    @breadcrumbs = [[t(:verificates)]]
    if params[:accounting_period_id]
      session[:accounting_period_id] = params[:accounting_period_id]
      @period = params[:accounting_period_id]
    elsif session[:accounting_period_id]
      @period = session[:accounting_period_id]
    else
      @period = @accounting_periods.last.id
      session[:accounting_period_id] = @period
    end
    @verificates = current_organization.verificates.where('accounting_period_id=?', @period).order(:number)
    @verificates = @verificates.order(:posting_date).page(params[:page]).decorate
  end

  # GET
  def new
    @accounting_period = current_organization.accounting_periods.find(session[:accounting_period_id])
    @verificate.accounting_period = @accounting_period
    @templates = current_organization.templates.where('accounting_plan_id = ?', @accounting_period.accounting_plan_id)
    gon.push root: AccountingPeriodSerializer.new(@accounting_period)
  end

  # GET
  def show
    @verificate = @verificate.decorate
    @accounting_period = @verificate.accounting_period
    gon.push root: AccountingPeriodSerializer.new(@accounting_period)

    if params[:import_bank_file_row_id]
      @verificate.import_bank_file_row_id = params[:import_bank_file_row_id]
      @verificate.save
    end
  end

  # GET
  def edit
  end

  # POST
  def create
    if !params[:template].blank?
      template = current_organization.templates.find(params[:template])
      params[:verificate][:description] = template.description + params[:verificate][:description]
    end
    @verificate = Verificate.new(verificate_params)
    @verificate.organization = current_organization
    respond_to do |format|
      if @verificate.save
        format.html { redirect_to verificate_path(@verificate), notice: "#{t(:verificate)} #{t(:was_successfully_created)}" }
      else
        flash.now[:danger] = "#{t(:failed_to_create)} #{t(:verificate)}"
        @accounting_period = @verificate.accounting_period
        gon.push root: AccountingPeriodSerializer.new(@accounting_period)
        @templates = current_organization.templates.where('accounting_plan_id = ?', @accounting_period.accounting_plan_id)
        format.html { render action: 'new' }
      end
    end
  end

  # PATCH/PUT
  def update
    respond_to do |format|
      if @verificate.update(verificate_params)
        format.html { redirect_to verificate_path, notice: "#{t(:verificate)} #{t(:was_successfully_updated)}" }
      else
        flash.now[:danger] = "#{t(:failed_to_update)} #{t(:verificate)}"
        @accounting_period = @verificate.accounting_period
        gon.push root: AccountingPeriodSerializer.new(@accounting_period)
        format.html { render action: 'show' }
      end
    end
  end

  # DELETE
  def destroy
    @verificate.destroy
    respond_to do |format|
      format.html { redirect_to verificates_path, notice:  "#{t(:verificate)} #{t(:was_successfully_deleted)}" }
    end
  end

  def state_change
    authorize! :manage, @verificate
    if @verificate.state_change(params[:event], params[:state_change_at])
      msg_h = { notice: t(:success) }
    else
      msg_h = { alert: t(:fail) }
    end
    @verificate.parent_type == 'ImportBankFileRow' ? url = import_bank_file_path(@verificate.parent.import_bank_file): url = verificates_url
    redirect_to url, msg_h
  end

  def add_verificate_items
    @verificate = current_organization.verificates.find(params[:id])
    @verificate_items_creator = Services::VerificateItemsCreator.new(current_organization, current_user, @verificate, params)
    respond_to do |format|
      if @verificate_items_creator.save
        @accounting_period = @verificate.accounting_period
        gon.push root: AccountingPeriodSerializer.new(@accounting_period)
        format.html { redirect_to verificate_path(@verificate), notice: "#{t(:verificate_items)} #{t(:was_successfully_created)}" }
      else
        flash.now[:danger] = "#{t(:failed_to_create)} #{t(:verificates_items)}"
        @accounting_period = @verificate.accounting_period
        gon.push root: AccountingPeriodSerializer.new(@accounting_period)
        format.html {  redirect_to verificate_path(@verificate)}
      end
    end
  end

  def reversal
    @verificate = current_organization.verificates.find(params[:id])
    @verificate_creator = Services::VerificateCreator.new(current_organization, current_user, @verificate, @verificate.posting_date)
    respond_to do |format|
      if @verificate_creator.reversal
        format.html { redirect_to verificates_path, notice:  "#{t(:verificate)} #{t(:was_successfully_created)}" }
      else
        format.html { redirect_to verificates_path, notice:  "#{t(:faild_to_create)} #{t(:verificate)}" }
      end
    end
  end

  private

  # Never trust parameters from the scary internet, only allow the white list through.
  def verificate_params
    params.require(:verificate).permit(Verificate.accessible_attributes.to_a)
  end

  def new_breadcrumbs
    @breadcrumbs = [[t(:verificates), verificates_path], ["#{t(:new)} #{t(:verificate)}"]]
  end

  def show_breadcrumbs
    @verificate.number ? bc = @verificate.number : bc = '*'
    if @verificate.parent_type == 'ImportBankFileRow'
       row = @verificate.parent
       file = @verificate.parent.import_bank_file
       @breadcrumbs = [["#{t(:import_bank_files)}", import_bank_files_path], 
                      [file.reference, import_bank_file_path(file)],
                      ["#{t(:matching)}", import_bank_file_import_bank_file_row_match_verificate_path(file, row)],
                      [bc]]
    else
      @breadcrumbs = [[t(:verificates), verificates_path], [bc]]
    end
  end

  def load_accounting_periods
    @accounting_periods = current_organization.accounting_periods.order('id')
    if @accounting_periods.size == 0
      redirect_to helps_show_message_path(message: "#{I18n.t(:accounting_period)} #{I18n.t(:missing)}")
    end
  end
end
