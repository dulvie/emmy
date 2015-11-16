class VatPeriodsController < ApplicationController
  respond_to :html, :json
  load_and_authorize_resource through: :current_organization

  before_filter :new_breadcrumbs, only: [:new, :create]
  before_filter :show_breadcrumbs, only: [:edit, :show, :update]
  before_filter :load_accounting_periods, only: [:index]

  def index
    @breadcrumbs = [[t(:vat_periods)]]
    if params[:accounting_period_id]
      session[:accounting_period_id] = params[:accounting_period_id]
      @period = params[:accounting_period_id]
    elsif session[:accounting_period_id]
      @period = session[:accounting_period_id]
    else
      @period = @accounting_periods.last.id
      session[:accounting_period_id] = @period
    end
    @vat_periods = current_organization.vat_periods.where('accounting_period_id=?', @period).order('id')
    @vat_periods = @vat_periods.page(params[:page]).decorate
  end

  def new
    @suppliers = current_organization.suppliers.where('supplier_type = ?', 'RSV')
    @accounting_period = current_organization.accounting_periods.find(session[:accounting_period_id])
    @vat_period = @accounting_period.next_vat_period
  end

  def show
  end

  def edit
    @suppliers = current_organization.suppliers.where('supplier_type = ?', 'RSV')
  end

  def create
    @vat_period = VatPeriod.new(vat_period_params)
    @vat_period.organization = current_organization
    respond_to do |format|
      if @vat_period.save
        format.html { redirect_to vat_periods_path, notice: "#{t(:vat_period)} #{t(:was_successfully_created)}" }
      else
        @suppliers = current_organization.suppliers.where('supplier_type = ?', 'RSV')
        flash.now[:danger] = "#{t(:failed_to_create)} #{t(:vat_period)}"
        format.html { render action: 'new' }
      end
    end
  end

  def update
    respond_to do |format|
      if @vat_period.update(vat_period_params)
        format.html { redirect_to vat_periods_path, notice: "#{t(:vat_period)} #{t(:was_successfully_updated)}" }
      else
        @suppliers = current_organization.suppliers.where('supplier_type = ?', 'RSV')
        flash.now[:danger] = "#{t(:failed_to_update)} #{t(:vat_period)}"
        format.html { render action: 'edit' }
      end
    end
  end

  def destroy
    @vat_period.destroy
    respond_to do |format|
      format.html { redirect_to vat_periods_path, notice: "#{t(:vat_period)} #{t(:was_successfully_deleted)}" }
    end
  end

  def state_change
    @vat_period = current_organization.vat_periods.find(params[:id])
    authorize! :manage, @vat_period
    if @vat_period.state_change(params[:event], DateTime.now, current_user.id)
      msg_h = { notice: t(:success) }
    else
      msg_h = { alert: t(:fail) }
    end
    redirect_to vat_periods_path, msg_h
  end

  private

  # Never trust parameters from the scary internet, only allow the white list through.
  def vat_period_params
    params.require(:vat_period).permit(VatPeriod.accessible_attributes.to_a)
  end

  def new_breadcrumbs
    @breadcrumbs = [[t(:vat_periods), vat_periods_path], ["#{t(:new)} #{t(:vat_period)}"]]
  end

  def show_breadcrumbs
    @breadcrumbs = [[t(:vat_periods), vat_periods_path], [@vat_period.name]]
  end

  def load_accounting_periods
    @accounting_periods = current_organization.accounting_periods.order('id')
    if @accounting_periods.size == 0
      redirect_to helps_show_message_path(message: "#{I18n.t(:accounting_period)} #{I18n.t(:missing)}")
    end
  end
end
