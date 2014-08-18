class ProductionBatchesController < ApplicationController
  skip_authorization_check
  before_filter :load_production
  before_filter :new_breadcrumbs, only: [:new, :create]

  respond_to :html

  def new
    @production_batch = ProductionBatch.new
    @production_batch.production_id = @production.id
    @items = Item.where("stocked=?", 'true')
    gon.push items: @items
  end

  def create
    @production_batch = ProductionBatch.new(production_batch_params)
    @production_batch.organisation_id = current_organisation.id
    respond_to do |format|
      if @production_batch.submit
        format.html { redirect_to edit_production_path(@production_batch.production_id), notice: 'batch was successfully created.'}
      else
        @production_batch.production_id = @production.id
        @items = Item.where("stocked=?", 'true')
        gon.push items: @items
        format.html { render action: 'new' }
      end
    end  
  end

  private
    def load_production
      @production = Production.find(params[:production_id])
    end

    def production_batch_params
      params.require(:production_batch).permit(:production_id, :item_id, :name, :comment, :in_price, :distributor_price, :retail_price,
        :refined_at, :expire_at, :quantity)
    end

    def new_breadcrumbs
      @breadcrumbs = [['Productions', productions_path], [@production.description, production_path(params['production_id'])], ["#{t(:new)} #{t(:production_batch)}"]]
    end
end