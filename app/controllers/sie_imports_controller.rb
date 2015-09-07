class SieImportsController < ApplicationController
  respond_to :html, :json

  def upload
    @breadcrumbs = [['Import SIE']]
    @sie_import = SieImport.new(current_organization, nil, nil)
    @accounting_periods = current_organization.accounting_periods
  end

  def create_from_upload
    uploaded = params[:sie_import][:upload]
    tempfile = uploaded.tempfile
    directory = "#{Rails.root}/tmp/uploads"
    file_name = "#{current_organization.slug}_sie_import.csv"
    path = File.join(directory, file_name)
    File.open(path, "wb") { |f| f.write(tempfile.read) }

    @accounting_period = current_organization.accounting_periods.find(params[:sie_import][:accounting_period])
    import_type = params[:sie_import][:import_type]
    @sie_trans = SieTransaction.new
    @sie_trans.execute = 'import'
    @sie_trans.complete = 'false'
    @sie_trans.directory = directory
    @sie_trans.file_name = file_name
    @sie_trans.sie_type = import_type
    @sie_trans.accounting_period_id = params[:sie_import][:accounting_period]
    @sie_trans.user = current_user
    @sie_trans.organization = current_organization

    @sie_import = SieImport.new(current_organization, @accounting_period, import_type)
    respond_to do |format|
      if @sie_import.valid? && @sie_trans.save
        if import_type == 'IB'
          url = edit_accounting_period_path(@accounting_period)  #OBS page reload
        elsif import_type == 'UB'
          url = closing_balance_path(@accounting_period.closing_balance)
        elsif import_type == 'Transactions'
          url = verificates_path + '&accounting_period_id=' + @accounting_period.id 
        else
          url = sie_imports_upload_path
        end
        format.html { redirect_to url, notice: "#{t(:file_uploaded)}" }
      else
        @accounting_periods = current_organization.accounting_periods
        flash.now[:danger] = "#{t(:file_upload)} #{t(:failed)}"
        format.html {render action: 'upload' }
      end
    end
  end

  private

end
