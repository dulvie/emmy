class ReversedVatsController < ApplicationController
  respond_to :html, :json
  load_and_authorize_resource through: :current_organization

  before_action :new_breadcrumbs, only: [:new, :create]
  before_action :show_breadcrumbs, only: [:edit, :show, :update]
  before_action :load_accounting_periods, only: [:index]

  def index
    @breadcrumbs = [[t(:reversed_vats)]]
    if params[:accounting_period_id]
      session[:accounting_period_id] = params[:accounting_period_id]
      @period = params[:accounting_period_id]
    elsif session[:accounting_period_id]
      @period = session[:accounting_period_id]
    else
      @period = @accounting_periods.last.id
      session[:accounting_period_id] = @period
    end
    @reversed_vats = current_organization.reversed_vats.where('accounting_period_id=?', @period).order('id')
    @reversed_vats = @reversed_vats.page(params[:page]).decorate
  end

  def new
    @accounting_period = current_organization.accounting_periods.find(session[:accounting_period_id])
    @reversed_vat = @accounting_period.next_reversed_vat
  end

  def show
    @reversed_vat_reports = @reversed_vat.reversed_vat_reports.page(params[:page])
  end

  def edit
    @reversed_vat_reports = @reversed_vat.reversed_vat_reports.page(params[:page])
  end

  def create
    @reversed_vat = ReversedVat.new(reversed_vat_params)
    @reversed_vat.organization = current_organization
    respond_to do |format|
      if @reversed_vat.save
        format.html { redirect_to reversed_vats_path, notice: "#{t(:reversed_vat)} #{t(:was_successfully_created)}" }
      else
        @accounting_period = current_organization.accounting_periods.find(session[:accounting_period_id])
        @reversed_vat = @accounting_period.next_reversed_vat
        flash.now[:danger] = "#{t(:failed_to_create)} #{t(:reversed_vat)}"
        format.html { render action: 'new' }
      end
    end
  end

  def update
    respond_to do |format|
      if @reversed_vat.update(reversed_vat_period_params)
        format.html { redirect_to reversed_vats_path, notice: "#{t(:reversed_vat)} #{t(:was_successfully_updated)}" }
      else
        @reversed_vat_reports = @reversed_vat.reversed_vat_reports.page(params[:page])
        flash.now[:danger] = "#{t(:failed_to_update)} #{t(:reversed_vat)}"
        format.html { render action: 'edit' }
      end
    end
  end

  def destroy
    @reversed_vat.destroy
    respond_to do |format|
      format.html { redirect_to reversed_vats_path, notice: "#{t(:reversed_vat)} #{t(:was_successfully_deleted)}" }
    end
  end

  def state_change
    @reversed_vat = current_organization.reversed_vats.find(params[:id])
    authorize! :manage, @reverse_vat
    if @reversed_vat.state_change(params[:event], DateTime.now, current_user.id)
      msg_h = { notice: t(:success) }
    else
      msg_h = { alert: t(:fail) }
    end
    redirect_to reversed_vats_path, msg_h
  end

  private

  # Never trust parameters from the scary internet, only allow the white list through.
  def reversed_vat_params
    params.require(:reversed_vat).permit(ReversedVat.accessible_attributes.to_a)
  end

  def new_breadcrumbs
    @breadcrumbs = [[t(:reversed_vats), reversed_vats_path], ["#{t(:new)} #{t(:reversed_vat)}"]]
  end

  def show_breadcrumbs
    @breadcrumbs = [[t(:reversed_vats), reversed_vats_path], [@reversed_vat.name]]
  end

  def load_accounting_periods
    @accounting_periods = current_organization.accounting_periods.order('id')
    if @accounting_periods.size == 0
      redirect_to helps_show_message_path(message: "#{I18n.t(:accounting_period)} #{I18n.t(:missing)}")
    end
  end
end
