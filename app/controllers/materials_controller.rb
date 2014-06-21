class MaterialsController < ApplicationController
  load_and_authorize_resource :production
  load_and_authorize_resource :material, through: :production

  #before_filter :set_breadcrumbs, only: [:new, :create]

  def new
     @production = @production
     @product_selections = Product.where(:item => Item.where(item_group: 'unrefined'))
  end

  def show
    @production = @production
    @product_selections = Product.where(:item => Item.where(item_group: 'unrefined'))
  end

  def create
    @production = Production.find(params[:production_id])
    @material = @production.materials.build material_params
    respond_to do |format|
      if @material.save
        format.html { redirect_to edit_production_path(@production), notice: "#{t(:material_added)}" }
      else
        flash.now[:danger] = "#{t(:failed_to_add)} #{t(:material)}"
        format.html { render :show }
      end
    end
  end

  def update
    @production = Production.find(params[:production_id])
    respond_to do |format|
      if @material.update_attributes(material_params)
        format.html { redirect_to edit_production_path(@production), notice: "#{t(:material)} #{t(:was_successfully_updated)}" }
      else
        flash.now[:danger] = "#{t(:failed_to_update)} #{t(:material)}"
        format.html { render :show }
        #format.json { render json: @sale.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @production = Production.find(params[:production_id])
    if @production.can_edit_items?
      item = @production.materials.find(params[:id])
      item.destroy
      msg = "#{t(:material)} #{t(:was_successfully_deleted)}"
    end

    respond_to do |format|
      format.html { redirect_to edit_production_path(@production), notice: msg }
      #format.json { head :no_content }
    end
  end

  private

    def material_params
      params.require(:material).permit(Material.accessible_attributes.to_a)
    end

    def set_breadcrumbs
      @breadcrumbs = [[t(:production), production_path], ["##{@production.id}", production_path(@production)], [t(:add_material)]]
    end
end
