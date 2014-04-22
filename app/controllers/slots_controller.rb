class SlotsController < ApplicationController
  load_and_authorize_resource :warehouse
  load_and_authorize_resource :through => :warehouse

  # GET /warehouses/:warehouse_id/slots/new
  def new
    @breadcrumbs = [
      ['Warehouses', warehouses_path],
      [@warehouse.name, edit_warehouse_path(@warehouse)],
      ['New slot']
    ]
  end

  # GET /warehouses/:warehouse_id/slots/:id/edit
  def edit
  end

  # POST /slots
  # POST /slots.json
  def create
    @slot = Slot.new_by_associations(slot_params)
    respond_to do |format|
      if @slot.save
        format.html { redirect_to edit_warehouse_path(@warehouse), notice: 'slot was successfully created.' }
        #format.json { render action: 'show', status: :created, location: @slot }
      else
        format.html { render action: 'new' }
        #format.json { render json: @slot.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /slots/1
  # DELETE /slots/1.json
  def destroy
    @slot.destroy
    respond_to do |format|
      format.html { redirect_to edit_warehouse_path(@warehouse)}
      format.json { head :no_content }
    end
  end

  private

    # Never trust parameters from the scary internet, only allow the white list through.
    def slot_params
      params.require(:slot).permit(:warehouse_id, :product_id, :quantity)
    end
end
