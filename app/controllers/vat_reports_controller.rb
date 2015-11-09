class VatReportsController < ApplicationController
  respond_to :html, :json
  load_and_authorize_resource :vat_period, through: :current_organization
  load_and_authorize_resource :vat_report, through: :current_organization

  before_filter :new_breadcrumbs, only: [:new, :create]
  before_filter :show_breadcrumbs, only: [:edit, :show, :update]

  # GET /vats
  # GET /vats.json
  def index
    init
  end

  # GET /vats/new
  def new
    @accounting_periods = current_organization.accounting_periods.where('active = ?', true).order('id')
    @vat_base = @accounting_periods.first.next_vat_base
  end

  # GET /vats/1
  def show
    @vat_period = VatPeriod.find(@vat_report.vat_period_id)
    @vat_report_creator = Services::VatReportCreator.new(current_organization, current_user, @vat_period)
    @tax_code = current_organization.tax_codes.find_by_code(params[:code])
    respond_to do |format|
      if @tax_code
        @items = @vat_report_creator.tax_code_part(@tax_code)
        format.html { render action: 'show' }
      else
        init
        flash.now[:danger] = "#{t(:fail)} #{t(:vat_report)}"
        format.html { render action: 'index' }
      end
    end
  end

  # GET /vat/1/edit
  def edit
    @accounting_periods = current_organization.accounting_periods.where('active = ?', true)
  end

  # POST /vats
  # POST /vats.json
  def create
    @vat_base = VatPeriod.new(vat_base_params)
    @vat_base.organization = current_organization
    respond_to do |format|
      if @vat_base.save
        format.html { redirect_to vat_bases_url, notice: 'Vat period was successfully created.' }
      else
        @accounting_periods = current_organization.accounting_periods.where('active = ?', true)
        flash.now[:danger] = "#{t(:failed_to_create)} #{t(:vat_base)}"
        format.html { render action: 'new' }
      end
    end
  end

  # PATCH/PUT /units/1
  # PATCH/PUT /units/1.json
  def update
    respond_to do |format|
      if @vat_base.update(vat_base_params)
        format.html { redirect_to vat_bases_url, notice: 'Vat period was successfully updated.' }
      else
        @accounting_periods = current_organization.accounting_periods.where('active = ?', true)
        flash.now[:danger] = "#{t(:failed_to_update)} #{t(:vat_base)}"
        format.html { render action: 'show' }
      end
    end
  end

  # DELETE /units/1
  # DELETE /units/1.json
  def destroy
    @vat_base.destroy
    respond_to do |format|
      format.html { redirect_to vat_bases_url, notice: 'Vat period was successfully deleted.' }
    end
  end

  private

  # Never trust parameters from the scary internet, only allow the white list through.
  def vat_base_params
    params.require(:vat_base).permit(VatPeriod.accessible_attributes.to_a)
  end

  def new_breadcrumbs
    @breadcrumbs = [[t(:vat_periods) vat_periods_path],[t(:vat_reports), vat_reports_path], ["#{t(:new)} #{t(:vat_report)}"]]
  end

  def show_breadcrumbs
    @breadcrumbs = [[t(:vat_periods), vat_periods_path], [@vat_report.vat_period.name, vat_period_path(@vat_report.vat_period_id)],
                    [t(:vat_reports), vat_period_vat_reports_path(@vat_report.vat_period_id)],
                    [@vat_report.code]]
  end

  def init
    @breadcrumbs = [[t(:vat_periods), vat_periods_path], [@vat_period.name, vat_period_path(@vat_period.id)],
                    [t(:vat_report)]]
    @vat_periods = current_organization.vat_periods.order('id')
    if !params[:vat_period_id] && @vat_periods.count > 0
      params[:vat_period_id] = @vat_periods.first.id
    end
    @vat_reports = current_organization.vat_reports.where('vat_period_id=?', params[:vat_period_id])
    @vat_reports = @vat_reports.page(params[:page])
  end
end
