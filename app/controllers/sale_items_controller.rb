class SaleItemsController < ApplicationController
  load_and_authorize_resource :sale
  load_and_authorize_resource :sale_item, through: :sale

  before_filter :set_breadcrumbs, only: [:new, :create]
  before_filter :init_new, only: [:new]

  def new
  end

  def create
    @sale_item = @sale.sale_items.build sale_item_params
    @sale_item.organisation = current_organisation

    @product_param = ProductParam.new(params[:sale_item][:product])
    @product_param.add_to(@sale_item)

    if @sale_item.save
      redirect_to sale_path(@sale), notice: "#{t(:batch_added)}"
    else
      init_new
      flash.now[:danger] = "#{t(:failed_to_add)} #{t(:batch)}"
      render :new
    end
  end

  def destroy
    @sale = Sale.find(params[:sale_id])
    msg = ''
    if @sale.can_edit_items?
      item = @sale.sale_items.find(params[:id])
      item.destroy
      msg = "#{t(:sale_item)} #{t(:was_successfully_deleted)}"
    end
    redirect_to @sale, notice: msg
  end

  private

  def init_new
    @sale = @sale.decorate
    @shelves = @sale.warehouse.shelves.includes(:batch)

    @products = Product.find_using_shelves(@shelves)
    if params[:sale_item] && params[:sale_item][:product]
      @selected_product = params[:sale_item][:product]
    else
      @selected_product = @products.first.value
    end
    @products.select{|p| p.value.eql?(@selected_product)}.first.selected = true

    gon.push products: @products
  end

  def sale_item_params
    params.require(:sale_item).permit(SaleItem.accessible_attributes.to_a)
  end

  def set_breadcrumbs
    @breadcrumbs = [[t(:sales), sales_path], ["##{@sale.id}", sale_path(@sale)], [t(:add_batch)]]
  end
end
