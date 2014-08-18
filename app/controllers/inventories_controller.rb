class InventoriesController < ApplicationController

  load_and_authorize_resource
  before_filter :new_breadcrumbs, only: [:new, :create]
  before_filter :show_breadcrumbs, only: [:show, :update, :edit, :state_change]

  def index
    @breadcrumbs = [['Inventories']]
    @inventories = Inventory.order('started_at DESC').page(params[:page]).per(8)
  end

  def show
  end

  def new
    @inventory.user = current_user
  end

  def create  
     @inventory = Inventory.new inventory_params
     @inventory.user = current_user
     @inventory.organisation = current_organisation
     respond_to do |format|
      if @inventory.save
        format.html { redirect_to inventory_path(@inventory), notice: "#{t(:inventory)} #{t(:was_successfully_created)}" }
      else
        flash.now[:danger] = "#{t(:failed_to_create)} #{t(:inventory)}"
        format.html { render action: :new }
      end      
    end
  end

  def update
    respond_to do |format|
      if @inventory.update(inventory_params)
        format.html { redirect_to inventory_path(@inventory), notice: 'inventory was successfully updated.' }
        #format.json { head :no_content }
      else
        flash.now[:danger] = "#{t(:failed_to_update)} #{t(:inventory)}"
        format.html { render action: 'show' }
        #format.json { render json: @inventory.errors, status: :unprocessable_entity }
      end
    end
  end

  def edit
  end


  def destroy
    @inventory.destroy
    respond_to do |format|
      format.html { redirect_to inventories_path, notice: "#{t(:inventory)} #{t(:was_successfully_deleted)}" }      
      #format.json { head :no_content }
    end
  end

  def state_change
    @inventory = Inventory.find(params[:id])
    if @inventory.state_change(params[:event], params[:state_change_at])
      msg = t(:success)
    else
      msg = @inventory.errors.first

    end
    respond_to do |format|
      return_path = inventory_path(@inventory)
      if params[:return_path]
        return_path = params[:return_path]
      end
      format.html { render 'show', notice: msg}
    end
  end

  private

    def inventory_params
      params.require(:inventory).permit(Inventory.accessible_attributes.to_a)
    end

    def new_breadcrumbs
      @breadcrumbs = [[t(:inventories), inventories_path], ["#{t(:new)} #{t(:inventory)}"]]
    end

    def show_breadcrumbs
      @breadcrumbs = [[t(:inventories), inventories_path], ["##{@inventory.id}"]]
    end

end
