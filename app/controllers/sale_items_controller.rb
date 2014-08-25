class SaleItemsController < ApplicationController
  load_and_authorize_resource :sale
  load_and_authorize_resource :sale_item, through: :sale

  before_filter :set_breadcrumbs, only: [:new, :create]

  def new
    @sale = @sale.decorate
    init_new
  end

  def create
    @sale = Sale.find(params[:sale_id])
    @sale_item = @sale.sale_items.build sale_item_params
    @sale_item.organisation = current_organisation
    respond_to do |format|
      if @sale_item.save
        format.html { redirect_to sale_path(@sale), notice: "#{t(:batch_added)}" }
      else
        flash.now[:danger] = "#{t(:failed_to_add)} #{t(:batch)}"
        init_new
        format.html {render action: 'new' }
      end
    end
  end

  def destroy
    @sale = Sale.find(params[:sale_id])
    if @sale.can_edit_items?
      item = @sale.sale_items.find(params[:id])
      item.destroy
      msg = "#{t(:sale_item)} #{t(:was_successfully_deleted)}"
    end

    respond_to do |format|
      format.html { redirect_to sale_path(@sale), notice: msg }
      #format.json { head :no_content }
    end
  end

  private
    def init_new
      @shelves = @sale.warehouse.shelves.includes(:batch)
      warehouse_batches = @sale.warehouse.batches_in_stock
      item_types = ['sales', 'both']
      @item_selections = Item.where(item_type: item_types, stocked: false) +
                         Item.where(item_type: item_types, stocked: true).joins(:batches).where(id: warehouse_batches)
      gon.push shelves: ActiveModel::ArraySerializer.new(@shelves, each_serializer: ShelfSerializer),
               items: ActiveModel::ArraySerializer.new(@item_selections, each_serializer: ItemSerializer)

    end

    def sale_item_params
      params.require(:sale_item).permit(SaleItem.accessible_attributes.to_a)
    end

    def set_breadcrumbs
      @breadcrumbs = [[t(:sales), sales_path], ["##{@sale.id}", sale_path(@sale)], [t(:add_batch)]]
    end
end
