class SieExportsController < ApplicationController
  respond_to :html, :json
  # load_and_authorize_resource :sie_export, through: :current_organization
  before_filter :load_accounting_periods, only: [:order]

  def order
    @breadcrumbs = [['Export SIE']]
    @sie_export = SieExport.new(current_organization, current_user, nil, nil)
    @trans = current_organization.sie_transactions.where("execute = 'export'").order('created_at DESC').first
  end

  def download
    @sie_export = SieExport.new(current_organization, current_user, nil, nil)
    @file = @sie_export.directory + '/' + @sie_export.file_name
    respond_to do |format|
      if @sie_export.file_exists?
        format.csv { send_file @file, type: 'text/plain', x_sendfile: true }
        format.html { redirect_to sie_export_order_path, notice: "#{t(:sie_exports)} #{t(:downloaded)}" }
      else
        @accounting_periods = current_organization.accounting_periods
        flash.now[:danger] = "#{t(:download)} #{t(:failed)}"
        format.html { redirect_to sie_export_order_path }
      end
    end
  end

  def create_file
    @sie_export = SieExport.new(current_organization, current_user, nil, nil)

    @sie_trans = SieTransaction.new
    @sie_trans.execute = 'export'
    @sie_trans.complete = 'false'
    @sie_trans.directory = @sie_export.directory
    @sie_trans.file_name = @sie_export.file_name
    @sie_trans.sie_type = params[:sie_export][:export_type]
    @sie_trans.accounting_period_id = params[:sie_export][:accounting_period]
    @sie_trans.user = current_user
    @sie_trans.organization = current_organization

    respond_to do |format|
      if @sie_trans.save
        format.html {redirect_to sie_exports_order_path, notice: "#{t(:sie_exports)} #{t(:was_successfully_created)}" }
      else
        @accounting_periods = current_organization.accounting_periods
        flash.now[:danger] = "#{t(:failed_to_create)} #{t(:sie_exports)}"
        format.html { redirect_to sie_export_order_path }
      end
    end
  end

  private

  def load_accounting_periods
    @accounting_periods = current_organization.accounting_periods
    if @accounting_periods.size == 0
      redirect_to helps_show_message_path(message: "#{I18n.t(:accounting_period)} #{I18n.t(:missing)}")
    end
  end
end
