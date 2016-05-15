class SieImportsController < ApplicationController
  respond_to :html, :json
  load_and_authorize_resource through: :current_organization

  before_filter :new_breadcrumbs, only: [:new, :create]
  before_filter :load_accounting_periods, only: [:new, :create]


  # GET
  def index
    @breadcrumbs = [[t(:sie_imports)]]
    @sie_imports = @sie_imports.page(params[:page]).decorate
  end

  def new
    # @sie_import = SieImport.new(current_organization, nil, nil)
  end

  # POST
  def create
    @sie_import = current_organization.sie_imports.build(sie_import_params)
    @sie_import.user = current_user
    @sie_import.import_date = DateTime.now
    respond_to do |format|
      if  @sie_import.save
        # url = new_sie_import_path
        # balances and transactions is created in background-jobs
        # if @sie_import.sie_type == 'IB'
        #  url = opening_balance_path(@sie_import.accounting_period.opening_balance)  # OBS page reload
        # elsif @sie_import.sie_type == 'UB'
        #  url = closing_balance_path(@sie_import.accounting_period.closing_balance)
        # elsif @sie_import.sie_type == 'Transactions'
        #  url = verificates_path + '&accounting_period_id=' + @sie_import.accounting_period.id.to_s
        # end
        format.html {
          redirect_to(sie_imports_path, notice: "#{t(:sie_imports)} #{t(:was_successfully_created)}")
        }
      else
        format.html {
          flash.now[:danger] = "#{t(:failed_to_create)} #{t(:sie_imports)}"
          render :new
        }
      end
    end
  end

  # DELETE
  def destroy
    @sie_import.destroy
    respond_to do |format|
      format.html { redirect_to sie_imports_path, notice:  "#{t(:sie_import)} #{t(:was_successfully_deleted)}" }
    end
  end

  private
  # Never trust parameters from the scary internet, only allow the white list through.
  def sie_import_params
    params.require(:sie_import).permit(SieImport.accessible_attributes.to_a)
    # params.permit(current_organization, current_user)
  end


  def new_breadcrumbs
    @breadcrumbs = [[t(:sie_imports), sie_imports_path],
                    ["#{t(:new)} #{t(:sie_import)}"]]
  end

  def load_accounting_periods
    @accounting_periods = current_organization.accounting_periods
    if @accounting_periods.size == 0
      redirect_to helps_show_message_path(message: "#{I18n.t(:accounting_period)} #{I18n.t(:missing)}")
    end
  end
end
