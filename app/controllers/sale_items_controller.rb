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
    warehouse_batches = @sale.warehouse.batches_in_stock
    item_types = ['sales', 'both']
    @item_selections = Item.where(item_type: item_types, stocked: false) +
                       Item.select('DISTINCT(items.id), items.*').where(item_type: item_types, stocked: true).joins(:batches).where(id: warehouse_batches)


    prod = Struct.new :value, :name
    @products = @shelves.collect{|s| prod.new("shelf_#{s.id}", s.batch.name)}
    @non_shelf_items = Item.sellable.not_stocked.collect{|i| prod.new("item_#{i.id}",i.name)}
    @products += @non_shelf_items
    gon.push shelves: ActiveModel::ArraySerializer.new(@shelves, each_serializer: ShelfSerializer),
             items: ActiveModel::ArraySerializer.new(@item_selections, each_serializer: ItemSerializer),
             products: @products
  end

  def sale_item_params
    params.require(:sale_item).permit(SaleItem.accessible_attributes.to_a)
  end

  def set_breadcrumbs
    @breadcrumbs = [[t(:sales), sales_path], ["##{@sale.id}", sale_path(@sale)], [t(:add_batch)]]
  end
end
