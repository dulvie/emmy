# encoding: utf-8
class ExportBankFilesController < ApplicationController
  respond_to :html, :json, :text
  load_and_authorize_resource through: :current_organization

  before_action :new_breadcrumbs, only: [:new, :create]
  before_action :show_breadcrumbs, only: [:edit, :show, :update]
  before_action :load_dependent, only: [:new]

  # GET
  def index
    @breadcrumbs = [["#{t(:export_bank_files)}"]]
    @export_bank_files = @export_bank_files.page(params[:page]).decorate
  end

  # GET
  def new
    @export_bank_file.pay_account = current_organization.bankgiro  #:postgiro, :plusgiro
    @export_bank_file.iban = current_organization.iban  #:postgiro, :plusgiro
    @export_bank_file.organization_number = current_organization.organization_number
  end

  # GET
  def show
    @export_bank_file_rows = @export_bank_file.export_bank_file_rows.page(params[:page]).decorate
    respond_to do |format|
      format.text { send_file @export_bank_file.download.path,
                              :file_name => @export_bank_file.download_file_name,
                              :type => @export_bank_file.download_content_type,
                              :disposition => 'attachment' }
      format.html {}
    end
  end

  # GET
  def edit
  end

  # POST
  def create
    @export_bank_file = ExportBankFile.new(export_bank_file_params)
    @export_bank_file.organization = current_organization
    @export_bank_file.user = current_user
    respond_to do |format|
      if @export_bank_file.save
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
      format.html { redirect_to export_bank_files_url, notice: "#{t(:export_bank_files)} #{t(:was_successfully_deleted)}" }
    end
  end

  private

  # Never trust parameters from the scary internet, only allow the white list through.
  def export_bank_file_params
    params.require(:export_bank_file).permit(:export_date, :from_date, :to_date, :reference, :pay_account,
                                             :organization_number, :iban, :download)
  end

  def new_breadcrumbs
    @breadcrumbs = [["#{t(:export_bank_files)}", export_bank_files_path],
                    ["#{t(:new)} #{t(:export_bank_file)}"]]
  end

  def show_breadcrumbs
    @breadcrumbs = [["#{t(:export_bank_files)}", export_bank_files_path],
                    [@export_bank_file.reference]]
  end

  def load_dependent
    @accounting_periods = current_organization.accounting_periods
    if @accounting_periods.size == 0
      redirect_to helps_show_message_path(message: "#{I18n.t(:accounting_period)} #{I18n.t(:missing)}")
    end
  end
end
