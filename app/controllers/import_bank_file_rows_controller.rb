class ImportBankFileRowsController < ApplicationController
  respond_to :html, :json
  load_and_authorize_resource :import_bank_file, through: :current_organization
  load_and_authorize_resource :import_bank_file_row, through: :current_organization

  before_action :new_breadcrumbs, only: [:new, :create]
  before_action :show_breadcrumbs, only: [:edit, :show, :update]
  before_action :load_dependent, only: [:match_verificate]

  # GET
  def index
    @breadcrumbs = [['import_bank_file_row']]
  end

  # GET
  def new
    accounting_period = current_organization.accounting_periods.last
    accounting_plan = current_organization.accounting_plans.find(accounting_period.accounting_plan_id)
    @accounting_groups = accounting_plan.accounting_groups.order(:number)
    @accounts = accounting_plan.accounts.order(:number)
  end

  # GET
  def show
    # Välj template
    ver_id = 0
    @verificates = current_organization.verificates.where('state = ?', 'preliminary')
    @verificates.each do |verificate|
      if verificate.bank_amount == @import_bank_file_row.amount
        verificate.posting_date = @import_bank_file_row.posting_date
        verificate.save
        ver_id = verificate.id
      end
    end
    if ver_id > 0
      redirect_to verificate_path(ver_id)
    else
      @import_bank_file_verificate = Services::ImportBankFileVerificate.new( @import_bank_file_row,
                                                                             @import_bank_file_row.posting_date)
      @import_bank_file_verificate.create
      redirect_to verificate_path(@import_bank_file_verificate.verificate_id)
    end

  end

  # GET
  def edit
  end

  # POST
  def create
    @template = current_organization.templates.find(params[:template_id])
    @import_bank_file_row = @template.import_bank_file_rows.build import_bank_file_row_params
    @import_bank_file_row.organization = current_organization
    respond_to do |format|
      if @import_bank_file_row.save
        format.html { redirect_to template_path(@template), notice: "#{t(:import_bank_file_row)} #{t(:was_successfully_created)}" }
      else
        flash.now[:danger] = "#{t(:failed_to_create)} #{t(:import_bank_file_row)}"
        format.html { render action: 'new' }
      end
    end
  end

  # PATCH/PUT
  def update
    respond_to do |format|
      if @import_bank_file_row.update(import_bank_file_row_params)
        format.html { redirect_to template_path(@template), notice: "#{t(:import_bank_file_row)} #{t(:was_successfully_updated)}" }
      else
        flash.now[:danger] = "#{t(:failed_to_update)} #{t(:import_bank_file_row)}"
        format.html { render action: 'show' }
      end
    end
  end

  # DELETE
  def destroy
    @import_bank_file_row.destroy
    respond_to do |format|
      format.html { redirect_to template_path(@template), notice:  "#{t(:import_bank_file_row)} #{t(:was_successfully_deleted)}" }
    end
  end

  def match_verificate
    @breadcrumbs = [["#{t(:import_bank_files)}", import_bank_files_path], 
                    [@import_bank_file.reference, import_bank_file_path(@import_bank_file)],
                    ["#{t(:matching)}"]]
    @import_bank_file_row = current_organization.import_bank_file_rows.find(params[:import_bank_file_row_id])
    @verificates ||= Array.new
    prel_verificates = current_organization.verificates.where('state = ?', 'preliminary')
    prel_verificates.each do |verificate|
      if verificate.bank_amount.abs == @import_bank_file_row.amount.abs || (verificate.parent_type == 'ImportBankFileRow' && verificate.parent_id == @import_bank_file_row.id)
        @verificates.push(verificate)
      end
    end
    template_type = 'cost'
    template_type = 'income' if @import_bank_file_row.amount > 0
    @templates = current_organization.templates.where('template_type = ?', template_type)
  end

  def set_template_verificate
    @import_bank_file_row = current_organization.import_bank_file_rows.find(params[:import_bank_file_row_id])
    @import_bank_file_verificate = Services::ImportBankFileVerificate.new( @import_bank_file_row,
                                                                           @import_bank_file_row.posting_date)
    respond_to do |format|
      if @import_bank_file_verificate.errors.size > 0
        flash.now[:danger] = "#{t(:issue_with_accouting_period)} #{t(:verificate)}"
        format.html { redirect_to @import_bank_file_row.import_bank_file }
      else
        @import_bank_file_verificate.template(params[:template_id])
        ver_id = @import_bank_file_verificate.verificate_id
        if ver_id > 0
          format.html { redirect_to verificate_path(ver_id) + "&bank_amount=" + @import_bank_file_row.amount.to_s, notice: 'Verificate was successfully updated.' }
        else
          flash.now[:danger] = "#{t(:failed_to_update)} #{t(:verificate)}"
          format.html { render action: 'match_verificate' }
        end
      end
    end
  end

  def set_verificate
    @import_bank_file_row = current_organization.import_bank_file_rows.find(params[:import_bank_file_row_id])
    @import_bank_file_verificate = Services::ImportBankFileVerificate.new( @import_bank_file_row,
                                                                           @import_bank_file_row.posting_date)
    respond_to do |format|
      @import_bank_file_verificate.create
      ver_id = @import_bank_file_verificate.verificate_id
      Rails.logger.info "==>#{ver_id}"
      if ver_id > 0
        format.html { redirect_to verificate_path(ver_id), notice: 'Verificate was successfully updated.' }
      else
        flash.now[:danger] = "#{t(:failed_to_update)} #{t(:verificate)}"
        format.html { render action: 'match_verificate' }
      end
    end
  end

  private

  # Never trust parameters from the scary internet, only allow the white list through.
  def import_bank_file_row_params
    params.require(:import_bank_file_row).permit(:posting_date, :amount, :bank_account, :name)
  end

  def new_breadcrumbs
    @breadcrumbs = [[t(:templates), templates_path],
                    [@template.name, template_path(@template)],
                    ["#{t(:new)} #{t(:import_bank_file_row)}"]]
  end

  def show_breadcrumbs
    # @breadcrumbs = [[t(:templates), templates_path], [@template.name, template_plan_path(@template)], [@import_bank_file_row.description]]
  end

  def load_dependent
    @accounting_periods = current_organization.accounting_periods
    if @accounting_periods.size == 0
      redirect_to helps_show_message_path(message: "#{I18n.t(:accounting_period)} #{I18n.t(:missing)}")
    end
  end
end
