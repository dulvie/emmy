class InventoryItemsController < ApplicationController

  respond_to :html, :json
  load_and_authorize_resource :inventory
  load_and_authorize_resource :inventory_item, through: :inventory

  before_filter :set_breadcrumbs, only: [:new, :create]

  def new
  end

  def create
    @inventory = Purchase.find(params[:inventory_id])
    @inventory_item = @inventory.inventory_items.build inventory_item_params
    @inventory_item.organisation = current_organisation
    respond_to do |format|
      if @inventory_item.save
        format.html { redirect_to inventory_path(@inventory), notice: "#{t(:batch_added)}" }
      else
        flash.now[:danger] = "#{t(:failed_to_add)} #{t(:batch)}"
        format.html { render :new }
      end
    end
  end

  def update
    respond_to do |format|
      if @inventory_item.update(inventory_item_params)
        format.html { redirect_to inventory_path(@inventory), notice: 'supplier was successfully updated.' }
        format.json { head :no_content }
      else
        flash.now[:danger] = "#{t(:failed_to_update)} #{t(:purchase)}"
        format.html { render action: 'show' }
        format.json { render json: @supplier.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @inventory = Inventory.find(params[:inventory_id])
    if @inventory.can_edit_items?
      item = @inventory.inventory_items.find(params[:id])
      item.destroy
      msg = "#{t(:inventory_item)} #{t(:was_successfully_deleted)}"
    end

    respond_to do |format|
      format.html { redirect_to inventory_path(@inventory), notice: msg }
      #format.json { head :no_content }
    end
  end

  private

    def inventory_item_params
      params.require(:inventory_item).permit(InventoryItem.accessible_attributes.to_a)
    end

    def set_breadcrumbs
      @breadcrumbs = [[t(:inventory), inventories_path], ["##{@inventory.id}", inventory_path(@inventory)], [t(:add_inventory)]]
    end

end
