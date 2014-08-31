# @TODO check state on update/destroy before doing anything.
class SalesController < ApplicationController
  load_and_authorize_resource

  before_filter :new_breadcrumbs, only: [:new, :create]
  before_filter :show_breadcrumbs, only: [:show, :update]

  def create
    @sale = Sale.new sale_params
    @sale.user = current_user
    @sale.organisation = current_organisation
    if @sale.save
      redirect_to sale_path(@sale), notice: "#{t(:sale)} #{t(:was_successfully_created)}"
    else
      flash.now[:danger] = "#{t(:failed_to_create)} #{t(:sale)}"
      render action: :new
    end
  end

  def index
    @breadcrumbs = [[t(:sales)]]
    if params[:state] == 'meta_complete'
      sales = @sales.where('state = ?', 'meta_complete').collect { |sale| sale.decorate }
    elsif params[:state] == 'prepared'
      sales = @sales.where('state = ?', 'prepared').collect { |sale| sale.decorate }
    elsif params[:money_state] == 'not_paid'
      sales = @sales.where('money_state = ?', 'not_paid').collect { |sale| sale.decorate }
    elsif params[:goods_state] == 'not_delivered'
      sales = @sales.where('goods_state = ?', 'not_delivered').collect { |sale| sale.decorate }
    else
      sales = @sales.order('approved_at DESC').collect { |sale| sale.decorate }
    end
    @sales = Kaminari.paginate_array(sales).page(params[:page]).per(8)
  end

  def new
  end

  def show
    @sale = @sale.decorate
    respond_to do |format|
      format.html
      format.pdf {
        render(
          pdf: "invoice_#{@sale.id}",
          template: 'sales/show.pdf.haml',
          layout: 'pdf'
        )
      }
    end
  end

  def update
    if @sale.update_attributes(sale_params)
      redirect_to sale_path(@sale), notice: "#{t(:sale)} #{t(:was_successfully_updated)}"
    else
      flash.now[:danger] = "#{t(:failed_to_update)} #{t(:sale)}"
      render action: :show
    end
  end

  def destroy
    @sale.destroy
    redirect_to sales_path, notice: "#{t(:sale)} #{t(:was_successfully_deleted)}"
  end

  def state_change
    @sale = Sale.find(params[:id])
    authorize! :manage, @sale
    if @sale.state_change(params[:event], params[:state_change_at])
      msg_h = { notice: t(:success) }
    else
      msg_h = { alert: t(:fail) }
    end
    redirect_to @sale, msg_h
  end

  def send_email
    @sale = Sale.find(params[:id])
    authorize! :manage, @sale
    if @sale.send_invoice!
      redirect_to sales_path, notice: t(:sent_email)
    else
      redirect_to sales_path, error: t(:unable_to_send_email)
    end
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
end
