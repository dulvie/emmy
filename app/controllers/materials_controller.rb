class MaterialsController < ApplicationController
  load_and_authorize_resource through: :current_organization
  load_and_authorize_resource :production, through: :current_organization

  before_filter :new_breadcrumbs, only: [:new, :create, :show]

  def new
    init_new
  end

  def show
    init_new
  end

  def create
    logger.info "batch: #{params[:material][:batch_id]}"

    @production = current_organization.productions.find(params[:production_id])
    @material = @production.materials.build material_params
    @material.organization = current_organization
    respond_to do |format|
      if @material.save
        format.html { redirect_to edit_production_path(@production), notice: "#{t(:material_added)}" }
      else
        flash.now[:danger] = "#{t(:failed_to_add)} #{t(:material)}"
        init_new
        format.html { render :show }
      end
    end
  end

  def update
    logger.info "batch: #{params[:material][:batch_id]}"
    @production = current_organization.productions.find(params[:production_id])
    respond_to do |format|
      if @material.update_attributes(material_params)
        format.html { redirect_to edit_production_path(@production), notice: "#{t(:material)} #{t(:was_successfully_updated)}" }
      else
        flash.now[:danger] = "#{t(:failed_to_update)} #{t(:material)}"
        init_new
        format.html { render :show }
        # format.json { render json: @sale.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @production = current_organization.productions.find(params[:production_id])
    if @production.can_edit?
      item = @production.materials.find(params[:id])
      item.destroy
      msg = "#{t(:material)} #{t(:was_successfully_deleted)}"
    end

    respond_to do |format|
      format.html { redirect_to edit_production_path(@production), notice: msg }
      # format.json { head :no_content }
    end
  end

  private

  def material_params
    params.require(:material).permit(Material.accessible_attributes.to_a)
  end

  def new_breadcrumbs
    @breadcrumbs = [[t(:productions), productions_path], ["#{@production.parent_name}", production_path(@production)], [t(:add_material)]]
  end

  def init_new
    #@batch_selections = @production.warehouse.shelves.select('batch_id', 'batch_id as id').where(batch: current_organization.batches.unrefined)
    @batch_selections = @production.warehouse.shelves.select('batch_id', 'batch_id as id')
      .where(batch: Batch.where(item: Item.where(item_group: 'unrefined')))
    gon.push shelves: ActiveModel::ArraySerializer.new(@production.warehouse.shelves, each_serializer: ShelfSerializer)
  end
end
