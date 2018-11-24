class ProductionBatchesController < ApplicationController
  load_and_authorize_resource :production, through: :current_organization
  before_action :new_breadcrumbs, only: [:new, :create]

  respond_to :html

  def new
    @production_batch = ProductionBatch.new
    @production_batch.production_id = @production.id
    @production_batch = @production_batch.decorate
    @items = current_organization.items.where('stocked=?', 'true')
    redirect_to helps_show_message_path(message: "#{I18n.t(:items)} #{I18n.t(:missing)}") if @items.size == 0
    gon.push items:  ActiveModel::Serializer::CollectionSerializer.new(@items, each_serializer: ItemSerializer)
  end

  def create
    @production_batch = ProductionBatch.new(production_batch_params)
    @production_batch.organization_id = current_organization.id
    @production_batch.production_id = @production.id
    respond_to do |format|
      if @production_batch.submit
        format.html { redirect_to edit_production_path(@production_batch.production_id), notice: 'batch was successfully created.' }
      else
        flash.now[:danger] = "#{t(:failed_to_add)} #{t(:batch)}"
        @production_batch.production_id = @production.id
        @items = current_organization.items.where('stocked=?', 'true')
        gon.push items: ActiveModel::Serializer::CollectionSerializer.new(@items, each_serializer: ItemSerializer)
        format.html { render action: 'new' }
      end
    end
  end


  private

  def production_batch_params
    params.require(:production_batch).permit(:production_id, :item_id, :name, :comment, :in_price, :distributor_price, :retail_price,
                                             :refined_at, :expire_at, :quantity)
  end

  def new_breadcrumbs
    @breadcrumbs = [['Productions', productions_path], [@production.description, production_path(params['production_id'])],
                    ["#{t(:new)} #{t(:production_batch)}"]]
  end
end
