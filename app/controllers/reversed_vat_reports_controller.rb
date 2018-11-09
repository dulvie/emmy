class ReversedVatReportsController < ApplicationController
  respond_to :html, :json
  load_and_authorize_resource :reversed_vat, through: :current_organization
  load_and_authorize_resource :reversed_vat_report, through: :current_organization

  before_action :new_breadcrumbs, only: [:new, :create]
  before_action :show_breadcrumbs, only: [:edit, :show, :update]

  def index
  end

  def new
  end

  def show
  end

  def edit
  end

  def create
    @reversed_vat_report = ReversedVatReport.new(reversed_vat_report_params)
    @reversed_vat_report.organization = current_organization
    respond_to do |format|
      if @reversed_vat_report.save
        format.html { redirect_to reversed_vats_report_path, notice: "#{t(:reversed_vat_report)} #{t(:was_successfully_created)}" }
      else
        flash.now[:danger] = "#{t(:failed_to_create)} #{t(:reversed_vat_report)}"
        format.html { render action: 'new' }
      end
    end
  end

  def update
    respond_to do |format|
      if @reversed_vat_report.update(reversed_vat_report_params)
        format.html { redirect_to reversed_vat_path(@reversed_vat), notice: "#{t(:reversed_vat_report)} #{t(:was_successfully_updated)}" }
      else
        flash.now[:danger] = "#{t(:failed_to_update)} #{t(:reversed_vat_report)}"
        format.html { render action: 'edit' }
      end
    end
  end

  def destroy
    @reversed_vat_report.destroy
    respond_to do |format|
      format.html { redirect_to reversed_vat_path(@reversed_vat), notice: "#{t(:reversed_vat_report)} #{t(:was_successfully_deleted)}" }
    end
  end


  private

  # Never trust parameters from the scary internet, only allow the white list through.
  def reversed_vat_report_params
    params.require(:reversed_vat_report).permit(:vat_number, :goods, :services, :third_part, :note,
                                                :accounting_period_id, :reversed_vat_id)
  end

  def new_breadcrumbs
    @breadcrumbs = [[t(:reversed_vats), reversed_vats_path],
                    [@reversed_vat.name, reversed_vat_path(@reversed_vat_report.reversed_vat_id)],
                    ["#{t(:new)} #{t(:reversed_vat_report)}"]]
  end

  def show_breadcrumbs
    @breadcrumbs = [[t(:reversed_vats), reversed_vats_path],
                    [@reversed_vat.name, reversed_vat_path(@reversed_vat_report.reversed_vat_id)],
                    [@reversed_vat_report.vat_number]]
  end

end
