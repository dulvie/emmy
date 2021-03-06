class TaxReturnsController < ApplicationController
  respond_to :html, :json
  load_and_authorize_resource through: :current_organization

  before_filter :new_breadcrumbs, only: [:new, :create]
  before_filter :show_breadcrumbs, only: [:edit, :show, :update]
  before_filter :load_dependence, only: [:index]

  def index
    @breadcrumbs = [[t(:tax_returns)]]
    if !params[:accounting_period_id] && @accounting_periods.count > 0
      params[:accounting_period_id] = @accounting_periods.first.id
    end
    @tax_returns = current_organization.tax_returns.where('accounting_period_id=?', params[:accounting_period_id]).order('id')
    @tax_returns = @tax_returns.page(params[:page]).decorate
  end

  def new
    @accounting_period = current_organization.accounting_periods.find(params[:accounting_period_id])
    @tax_return = @accounting_period.default_tax_return
  end

  def show
  end

  def edit
  end

  def create
    @tax_return = TaxReturn.new(tax_return_params)
    @tax_return.organization = current_organization
    respond_to do |format|
      if @tax_return.save
        url = tax_returns_path + '&accounting_period_id=' + @tax_return.accounting_period_id.to_s
        format.html { redirect_to url, notice: "#{t(:tax_return)} #{t(:was_successfully_created)}" }
      else
        flash.now[:danger] = "#{t(:failed_to_create)} #{t(:tax_return)}"
        format.html { render action: 'show' }
      end
    end
  end

  def update
    respond_to do |format|
      if @tax_return.update(tax_return_params)
        url = tax_returns_path + '&accounting_period_id=' + @tax_return.accounting_period_id.to_s
        format.html { redirect_to url, notice: "#{t(:tax_return)} #{t(:was_successfully_updated)}" }
      else
        @accounting_periods = current_organization.accounting_periods.where('active = ?', true)
        flash.now[:danger] = "#{t(:failed_to_update)} #{t(:tax_return)}"
        format.html { render action: 'edit' }
      end
    end
  end

  def destroy
    url = tax_returns_path + '&accounting_period_id=' + @tax_return.accounting_period_id.to_s
    @tax_return.destroy
    respond_to do |format|
      format.html { redirect_to url, notice: "#{t(:tax_return)} #{t(:was_successfully_deleted)}" }
    end
  end

  def state_change
    @tax_return = current_organization.tax_returns.find(params[:id])
    authorize! :manage, @tax_return
    if @tax_return.state_change(params[:event], DateTime.now, current_user.id)
      msg_h = { notice: t(:success) }
    else
      msg_h = { alert: t(:fail) }
    end
    redirect_to tax_returns_path, msg_h
  end

  private

  # Never trust parameters from the scary internet, only allow the white list through.
  def tax_return_params
    params.require(:tax_return).permit(TaxReturn.accessible_attributes.to_a)
  end

  def new_breadcrumbs
    @breadcrumbs = [[t(:tax_returns), tax_returns_path], ["#{t(:new)} #{t(:tax_return)}"]]
  end

  def show_breadcrumbs
    @breadcrumbs = [[t(:tax_returns), tax_returns_path], [@tax_return.name]]
  end

  def load_dependence
    @accounting_periods = current_organization.accounting_periods.where('active = ?', true).order('id')
    if @accounting_periods.size == 0
      redirect_to helps_show_message_path(message: "#{I18n.t(:accounting_periods)} #{I18n.t(:missing)}")
    end
  end
end
