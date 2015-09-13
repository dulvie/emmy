# encoding: utf-8
class ExportBankFilesController < ApplicationController
  respond_to :html, :json
  load_and_authorize_resource through: :current_organization

  before_filter :new_breadcrumbs, only: [:new, :create]
  before_filter :show_breadcrumbs, only: [:edit, :show, :update]
  before_filter :load_dependent, only: [:new]

  # GET
  def index
    @breadcrumbs = [["#{t(:export_bank_files)}"]]
    @export_bank_files = @export_bank_files.page(params[:page]).decorate
  end

  # GET
  def new
    @export_bank_file.pay_account = current_organization.bankgiro  #:postgiro, :plusgiro
    @export_bank_file.iban = current_organization.iban  #:postgiro, :plusgiro
    @export_bank_file.organization_number = current_organization.vat_number
  end

  # GET
  def show
    @export_bank_file_rows = @export_bank_file.export_bank_file_rows.page(params[:page]).decorate
  end

  # GET
  def edit
  end

  # POST
  def create
    @export_bank_file = ExportBankFile.new(export_bank_file_params)
    @export_bank_file.organization = current_organization
    respond_to do |format|
      if @export_bank_file.save
        export_bank_file_rows = Services::ExportBankFileCreator.new(current_organization, current_user, @export_bank_file)
        export_bank_file_rows.read_verificates_and_create_rows if @export_bank_file.reference == 'Fakturabetalning'
        export_bank_file_rows.read_wages_and_create_rows if @export_bank_file.reference == 'Löneutbetalning'
        format.html { redirect_to export_bank_files_url, notice: "#{t(:export_bank_file)} #{t(:was_successfully_created)}" }
      else
        flash.now[:danger] = "#{t(:failed_to_create)} #{t(:export_bank_file)}"
        format.html { render action: 'new' }
      end
    end
  end

  # PATCH/PUT
  def update
  end

  # DELETE
  def destroy
    @export_bank_file.destroy
    respond_to do |format|
      format.html { redirect_to export_bank_files_url, notice:  "#{t(:export_bank_files)} #{t(:was_successfully_deleted)}" }
    end
  end

  def download
    export_bank_file = current_organization.export_bank_files.find(params[:export_bank_file_id])
    export = Services::ExportBankFileCreator.new(current_organization, current_user, export_bank_file)
    respond_to do |format|
      # if export.create_file_PO3
      if export.test_file_PO3
        format.csv { send_file 'tmp/downloads/bank_file.txt', :type=>"text/plain", :x_sendfile=>true }
        format.html { redirect_to export_bank_files_url, notice: "#{t(:export_bank_file)} #{t(:was_successfully_created)}" }
      else
        flash.now[:danger] = "#{t(:failed_to_create)} #{t(:export_bank_file)}"
        format.html { redirect_to export_bank_files_url, notice:"#{t(:failed_to_create)} #{t(:export_bank_file)}" }
      end
    end
  end

  private

  # Never trust parameters from the scary internet, only allow the white list through.
  def export_bank_file_params
    params.require(:export_bank_file).permit(ExportBankFile.accessible_attributes.to_a)
  end

  def new_breadcrumbs
    @breadcrumbs = [["#{t(:export_bank_files)}", export_bank_files_path], ["#{t(:new)} #{t(:export_bank_file)}"]]
  end

  def show_breadcrumbs
   @breadcrumbs = [["#{t(:export_bank_files)}", export_bank_files_path], [@export_bank_file.reference]]
  end

  def load_dependent
    @accounting_periods = current_organization.accounting_periods
    unless @accounting_periods
      redirect_to helps_show_message_path(message: I18n.t(:accounting_period_missing))
    end
  end
end
