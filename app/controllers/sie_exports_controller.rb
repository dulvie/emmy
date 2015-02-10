class SieExportsController < ApplicationController
  respond_to :html, :json

  def order_export
    @breadcrumbs = [['Export SIE']]
    @accounting_periods = current_organization.accounting_periods
    @sie_export = SieExport.new(current_organization, current_user, nil, nil)
  end

  def create_export
    @accounting_period = current_organization.accounting_periods.find(params[:sie_export][:accounting_period])
    export_type = params[:sie_export][:export_type]
    @ledger = current_organization.ledgers.where('accounting_period_id = ? ', @accounting_period.id).first
    @sie_export = SieExport.new(current_organization, current_user, @accounting_period, @ledger)
    @sie_export.export_type = export_type

    #send_file( 'tmp/downloads/export.sie', :type => 'text', :filename => 'export.sie',:dispostion=>'attachment',:status=>'200 OK',:stream=>'true' )
      respond_to do |format|

      if @sie_export.execute
        format.csv {     send_file 'tmp/downloads/export.sie', :type=>"text/plain", :x_sendfile=>true }
        # send_data f, :disposition => 'attachment', :filename=>"export.sie"
        format.html { render action: 'order_export', notice: "#{t(:sie_export)} #{t(:was_successfully_created)}" }
      else
        @accounting_periods = current_organization.accounting_periods
        flash.now[:danger] = "#{t(:failed_to_create)} #{t(:export)}"
        format.html { render action: 'order_export' }
      end
    end
  end 

  def xx

  end

  private

end
