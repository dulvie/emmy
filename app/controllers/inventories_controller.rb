class InventoriesController < ApplicationController
  load_and_authorize_resource through: :current_organization
  before_action :new_breadcrumbs, only: [:new, :create]
  before_action :show_breadcrumbs, only: [:show, :update, :edit, :state_change]

  def index
    @breadcrumbs = [[t(:inventories)]]
    @inventories = @inventories.order('started_at DESC').page(params[:page]).decorate
  end

  def show
    @warehouses = current_organization.warehouses
    @invent = @inventory
    @inventory = @inventory.decorate
  end

  def new
    @warehouses = current_organization.warehouses
    redirect_to helps_show_message_path(message: "#{I18n.t(:warehouses)} #{I18n.t(:missing)}") if @warehouses.size == 0
  end

  def create
    @inventory = Inventory.new inventory_params
    @inventory.user = current_user
    @inventory.organization = current_organization
    respond_to do |format|
      if @inventory.save
        format.html { redirect_to inventory_path(@inventory), notice: "#{t(:inventory)} #{t(:was_successfully_created)}" }
      else
        flash.now[:danger] = "#{t(:failed_to_create)} #{t(:inventory)}"
        @warehouses = current_organization.warehouses
        format.html { render action: :new }
      end
    end
  end

  def update
    respond_to do |format|
      if @inventory.update(inventory_params)
        format.html { redirect_to inventory_path(@inventory), notice: 'inventory was successfully updated.' }
        # format.json { head :no_content }
      else
        @inventory = @inventory.decorate
        flash.now[:danger] = "#{t(:failed_to_update)} #{t(:inventory)}"
        format.html { render action: 'show' }
        # format.json { render json: @inventory.errors, status: :unprocessable_entity }
      end
    end
  end

  def edit
  end

  def destroy
    @inventory.destroy
    respond_to do |format|
      format.html { redirect_to inventories_path, notice: "#{t(:inventory)} #{t(:was_successfully_deleted)}" }
      # format.json { head :no_content }
    end
  end

  def state_change
    @warehouses = current_organization.warehouses
    @inventory = current_organization.inventories.find(params[:id])
    if @inventory.state_change(params[:event], params[:state_change_at])
      msg = t(:success)
    else
      msg = @inventory.errors.first
    end
    respond_to do |format|
      format.html { redirect_to inventory_path(@inventory), notice: msg }
    end
  end

  private

  def inventory_params
    params.require(:inventory).permit(:description, :user_id, :warehouse_id, :inventory_date)
  end

  def new_breadcrumbs
    @breadcrumbs = [[t(:inventories), inventories_path], ["#{t(:new)} #{t(:inventory)}"]]
  end

  def show_breadcrumbs
    @breadcrumbs = [[t(:inventories), inventories_path], ["##{@inventory.id}"]]
  end
end
