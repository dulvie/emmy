# @TODO check state on update/destroy before doing anything.
class SalesController < ApplicationController
  load_and_authorize_resource through: :current_organization

  before_filter :new_breadcrumbs, only: [:new, :create]
  before_filter :show_breadcrumbs, only: [:show, :update]
  before_filter :add_warehouses, only: [:index, :new, :invoice_search]

  def create
    @sale = Sale.new sale_params
    @sale.user = current_user
    @sale.organization = current_organization
    if @sale.save
      redirect_to sale_path(@sale), notice: "#{t(:sale)} #{t(:was_successfully_created)}"
    else
      flash.now[:danger] = "#{t(:failed_to_create)} #{t(:sale)}"
      @warehouses = current_organization.warehouses
      render action: :new
    end
  end

  def index
    @breadcrumbs = [[t(:sales)]]
    @warehouses = current_organization.warehouses

    @sales = @sales.send(state_param.to_sym) if state_param
    @sales = @sales.where(warehouse_id: params[:warehouse_id]) unless params[:warehouse_id].blank?
    @sales = @sales.where(user_id: params[:user_id]) unless params[:user_id].blank?
    @sales = @sales.where(invoice_number: params[:invoice_number]) unless params[:invoice_number].blank?
    if !params[:invoice_number].blank? && @sales.size == 1
      redirect_to sale_path(@sales.first)
    end
    @sales = @sales.page(params[:page]).decorate
  end

  def new
    @warehouses = current_organization.warehouses
    @sale.customer_id = params[:customer_id] if params[:customer_id]
  end

  def show
    @sale = @sale.decorate
    respond_to do |format|
      format.html { @warehouses = current_organization.warehouses }
      format.pdf do
        render(pdf: "invoice_#{@sale.id}",
               template: 'sales/show.pdf.haml',
               layout: 'pdf')
      end
    end
  end

  def update
    if @sale.update_attributes(sale_params)
      redirect_to sale_path(@sale), notice: "#{t(:sale)} #{t(:was_successfully_updated)}"
    else
      flash.now[:danger] = "#{t(:failed_to_update)} #{t(:sale)}"
      @warehouses = current_organization.warehouses
      render action: :show
    end
  end

  def destroy
    @sale.destroy
    redirect_to sales_path, notice: "#{t(:sale)} #{t(:was_successfully_deleted)}"
  end

  def state_change
    @sale = current_organization.sales.find(params[:id])
    authorize! :manage, @sale
    if @sale.state_change(params[:event], params[:state_change_at])
      msg_h = { notice: t(:success) }
    else
      msg_h = { alert: t(:fail) }
    end
    redirect_to @sale, msg_h
  end

  def send_email
    @sale = current_organization.sales.find(params[:id])
    authorize! :manage, @sale
    if @sale.send_invoice!
      flash[:notice] = t(:sent_email)
    else
      flash[:danger] = "#{t(:unable_to_send_email)}: #{@sale.errors[:custom_error].join(',')}"
    end
    redirect_to sales_path
  end

  private

  def sale_params
    params.require(:sale).permit(Sale.accessible_attributes.to_a)
  end

  def new_breadcrumbs
    @breadcrumbs = [[t(:sales), sales_path], ["#{t(:new)} #{t(:sale)}"]]
  end

  def show_breadcrumbs
    @breadcrumbs = [[t(:sales), sales_path], ["##{@sale.id}"]]
  end

  def state_param
    p = params.permit([:state, :locale, 'organization-slug'])
    if p[:state] && Sale::FILTER_STAGES.include?(p[:state].to_sym)
      p[:state]
    else
      nil
    end
  end

  def add_warehouses
    @warehouses = current_organization.warehouses
  end
end
