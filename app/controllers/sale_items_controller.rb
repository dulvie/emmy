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
    @item_creator = Service::SaleItemCreator.new(@sale, @sale_item, params)
    if @item_creator.save
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
    @products = @shelves.collect{|s| s.to_product }
    @non_shelf_items = Item.sellable.not_stocked.collect{|i| i.to_product }
    @products += @non_shelf_items
    @selected_product = @products.first.value
    # If there is an item creator object, something went wrong during #create.
    if @item_creator

      @sale_item = @item_creator.sale_item
      logger.info "errors: #{@sale_item.errors.full_messages}"
      # Add the selected flag.

      selected_product = @products.select{|p| p.value.eql?(@item_creator.value) }.first
      selected_product.selected = true
      @selected_product = selected_product.value

    end
    gon.push products: @products
  end

  def sale_item_params
    params.require(:sale_item).permit(SaleItem.accessible_attributes.to_a)
  end

  def set_breadcrumbs
    @breadcrumbs = [[t(:sales), sales_path], ["##{@sale.id}", sale_path(@sale)], [t(:add_batch)]]
  end
end
