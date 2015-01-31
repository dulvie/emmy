class SieImportsController < ApplicationController
  respond_to :html, :json

  def order_import
    @breadcrumbs = [['Import SIE']]
    @sie_import = SieImport.new(current_organization)
    @accounting_periods = current_organization.accounting_periods
  end

  def create_import
    @sie_import = SieImport.new(current_organization)
    @sie_import.accounting_period_id = params[:sie_import][:accounting_period]
    @sie_import.import_type = params[:sie_import][:import_type]

    respond_to do |format|
      if @sie_import.valid?
        import_type = params[:sie_import][:import_type]
        accounting_period = current_organization.accounting_periods.find(params[:sie_import][:accounting_period])
        accounting_plan = accounting_period.accounting_plan
        @import_sie = Services::ImportSie.new(current_organization, current_user, accounting_period, accounting_plan)
        Rails.logger.info "->#{import_type}"
        if @import_sie.read_and_save(import_type)
          url = opening_balance_path(accounting_period.opening_balance)
          url = closing_balance_path(accounting_period.closing_balance) if import_type == 'UB'
          url = verificates_path + '&accounting_period_id=' + accounting_period.id if import_type == 'Transactions' 
          format.html { redirect_to url, notice: "#{t(:sie_import)} #{t(:was_successfully_created)}" }
        else
          @accounting_periods = current_organization.accounting_periods
          flash.now[:danger] = "#{t(:failed_to_create)} #{t(:import)}"
          format.html {render action: 'order_import' }
        end
      else
        @accounting_periods = current_organization.accounting_periods
        flash.now[:danger] = "#{t(:failed_to_create)} #{t(:import)}"
        format.html { render action: 'order_import' }
      end
    end
  end

  private

end
