# @TODO check state on update/destroy before doing anything.
class SalesController < ApplicationController
  load_and_authorize_resource

  before_filter :new_breadcrumbs, only: [:new, :create]
  before_filter :show_breadcrumbs, only: [:show, :update]

  def create
    @sale = Sale.new sale_params
    @sale.user = current_user
    respond_to do |format|
      if @sale.save
        format.html { redirect_to sale_path(@sale), notice: "#{t(:sale)} #{t(:was_successfully_created)}" }
      else
        flash.now[:danger] = "#{t(:failed_to_create)} #{t(:sale)}"
        format.html { render action: :new }
        #format.json { render json: @sale.errors, status: :unprocessable_entity }
      end
    end

  end

  def index
    @breadcrumbs = [[t(:sales)]]
    if params[:state] == 'meta_complete'
      sales = @sales.where("state = ?", 'meta_complete').collect{|sale| sale.decorate}
    elsif params[:state] == 'item_complete'
      sales = @sales.where("state = ?", 'item_complete').collect{|sale| sale.decorate}
    elsif params[:money_state] == 'not_paid'
      sales = @sales.where("money_state = ?", 'not_paid').collect{|sale| sale.decorate}
    elsif params[:goods_state] == 'not_delivered'
      sales = @sales.where("goods_state = ?", 'not_delivered').collect{|sale| sale.decorate}
    else
      sales = @sales.order("approved_at DESC").collect{|sale| sale.decorate}
    end
    @sales = Kaminari.paginate_array(sales).page(params[:page]).per(8)
  end

  def new
  end

  def show
    @sale = @sale.decorate
    respond_to do |format|
      format.pdf {
        render(
          pdf: "invoice_#{@sale.id}",
          template: 'sales/show.pdf.haml',
          layout: 'pdf'
        )
      }
      format.html
    end
  end

  def update
    respond_to do |format|
      if @sale.update_attributes(sale_params)
        format.html { redirect_to sale_path(@sale), notice: "#{t(:sale)} #{t(:was_successfully_updated)}" }
      else
        flash.now[:danger] = "#{t(:failed_to_update)} #{t(:sale)}"
        format.html { render action: :show }
        #format.json { render json: @sale.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @sale.destroy
    respond_to do |format|
      format.html { redirect_to sales_path, notice: "#{t(:sale)} #{t(:was_successfully_deleted)}" }
      #format.json { head :no_content }
    end
  end

  def state_change
    @sale = Sale.find(params[:id])
    if @sale.state_change(params[:new_state], params[:state_change_at])
      msg = t(:success)
    else
      msg = t(:fail)
    end
    respond_to do |format|
      format.html { redirect_to @sale, notice: msg}
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
