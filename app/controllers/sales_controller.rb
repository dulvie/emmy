# @TODO check state on update/destroy before doing anything.
class SalesController < ApplicationController
  load_and_authorize_resource through: :current_organization

  before_filter :new_breadcrumbs, only: [:new, :create]
  before_filter :show_breadcrumbs, only: [:show, :update]
  before_filter :add_warehouses, only: [:index, :new, :invoice_search]
  before_filter :add_search_filter, only: [:index]

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
    @sales = @sales.order 'approved_at desc'
    @sales = @sales.page(params[:page]).decorate
    respond_to do |format|
      format.csv
      format.pdf do
        render(pdf: 'invoices', template: 'sales/index.pdf.haml', layout: 'pdf')
      end
      format.html
    end
  end

  def new
    @warehouses = current_organization.warehouses
    @sale.customer_id = params[:customer_id] if params[:customer_id]
  end

  def show
    @object = @sale
    @sale = @sale.decorate
    respond_to do |format|
      format.html { @warehouses = current_organization.warehouses }
      format.pdf do
        if params.has_key?('regenerate')
          render(pdf: "invoice_#{@sale.invoice_number}",
                 template: 'sales/show.pdf.haml',
                 layout: 'pdf')
        elsif @sale.document.nil?
          fail ArgumentError
        else
          send_file(@sale.document.upload.path,
                    filename: "invoice_#{@sale.invoice_number}.pdf",
                    type: 'application/pdf')
        end
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
    if @sale.can_delete?
      @sale.destroy
      redirect_to sales_path, notice: "#{t(:sale)} #{t(:was_successfully_deleted)}"
    else
      redirect_to sales_path, alert: "#{t(:sale)} #{t('errors.messages.can_not_be_deleted')}"
    end
  end

  def state_change
    @sale = current_organization.sales.find(params[:id])
    deliver = params[:sale].nil? ? nil : params[:sale][:report_delivery]
    authorize! :manage, @sale
    if @sale.state_change(params[:event], params[:state_change_at], deliver)
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

  def regenerate_invoice
    @sale.document.destroy if @sale.document
    @sale.generate_invoice
    redirect_to @sale
  end

  private

  def sale_params
    params.require(:sale).permit(Sale.accessible_attributes.to_a)
  end

  def new_breadcrumbs
    @breadcrumbs = [[t(:sales), sales_path], ["#{t(:new)} #{t(:sale)}"]]
  end

  def show_breadcrumbs
    @breadcrumbs = [[t(:sales), sales_path], ["##{@sale.invoice_number}"]]
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

  def add_search_filter
    search_params.each do |key, value|
      @sales = @sales.where(key => value) if value
    end

    if search_params[:invoice_number] && @sales.size == 1
      redirect_to sale_path(@sales.first)
    end

    add_date_constraint(:newer_than) unless params[:newer_than].blank?
    add_date_constraint(:older_than) unless params[:older_than].blank?

    # Uses a named scope.
    @sales = @sales.send(state_param.to_sym) if state_param
  end

  # Create a hash with all the keys, set value to nil unless exist in params.
  def search_params
    unless @search_params
      @search_params = {}.with_indifferent_access
      [:warehouse_id, :user_id, :invoice_number].map do |key|
        @search_params[key] = (!params[key].blank?) ? params[key].to_s : nil
      end
    end
    @search_params
  end

  def add_date_constraint(direction)
    d = (direction.eql? :newer_than) ? '>' : '<'
    @sales = @sales.where("approved_at #{d} ?", date_param(direction))
  end

  # Only allow numers and - as date params.
  # Return the passed year/month the first in that month.
  def date_param(direction)
    return "#{params[direction]}-01" if params[direction].match(/^[0-9]{4}-[0-9]{2}$/)
    fail ArgumentError
  end
end
