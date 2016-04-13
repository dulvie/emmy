class SieExportsController < ApplicationController
  respond_to :html, :txt
  load_and_authorize_resource :sie_export, through: :current_organization
  before_filter :load_accounting_periods, only: [:new, :create, :show]
  before_filter :new_breadcrumbs, only: [:new, :create]
  before_filter :show_breadcrumbs, only: [:edit, :show, :update]

  def index
    @breadcrumbs = [['SIE Exports']]
    @sie_exports = @sie_exports.page(params[:page]).decorate
  end

  def show
    respond_to do |format|
      format.text { send_file @sie_export.download.path,
                      :filename => @sie_export.download_file_name,
                      :type => @sie_export.download_content_type,
                      :disposition => 'attachment'}

      format.html { }
    end
  end

  def new
  end

  def create
    @sie_export = SieExport.new(sie_export_params)
    @sie_export.organization = current_organization
    @sie_export.user = current_user
    @sie_export.export_date = DateTime.now
    respond_to do |format|
      if @sie_export.save
        format.html { redirect_to sie_exports_path, notice: "#{t(:sie_export)} #{t(:was_successfully_created)}" }
      else
        flash.now[:danger] = "#{t(:failed_to_create)} #{t(:sie_export)}"
        format.html { render action: 'new' }
      end
    end
  end

  def destroy
    @sie_export.destroy
    redirect_to sie_exports_path, notice: "#{t(:sie_export)} #{t(:was_successfully_deleted)}"
  end

  private
  # Never trust parameters from the scary internet, only allow the white list through.
  def sie_export_params
    params.require(:sie_export).permit(SieExport.accessible_attributes.to_a)
    # params.permit(current_organization, current_user)
  end

  def new_breadcrumbs
    @breadcrumbs = [[t(:sie_exports), sie_exports_path],
                    ["#{t(:new)} #{t(:sie_export)}"]]
  end

  def show_breadcrumbs
    @breadcrumbs = [[t(:sie_exports), sie_exports_path],
                    ['SIE Export']]
  end

  def load_accounting_periods
    @accounting_periods = current_organization.accounting_periods
    if @accounting_periods.size == 0
      redirect_to helps_show_message_path(message: "#{I18n.t(:accounting_period)} #{I18n.t(:missing)}")
    end
  end
end
