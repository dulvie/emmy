class SlotChangesController < ApplicationController
  load_and_authorize_resource :warehouse
  load_and_authorize_resource :slot, :through => :warehouse
  load_and_authorize_resource :through => :slot

  # GET /warehouses/:warehouse_id/slots/:slot_id/slot_changes
  def index
  end

  # GET /warehouses/:warehouse_id/slots/:slot_id/slot_changes/new
  def new
    # @note Not sure why this is needed, and if there is some
    # load_and_authorize option that can be used so this is not needed.
    @slot_change.slot_id = @slot.id
  end

  # POST /warehouses/:warehouse_id/slots/:slot_id/slot_changes
  def create
    @slot_change = current_user.slot_changes.new_by_change_type(slot_change_params[:change_type], slot_change_params)


    respond_to do |format|
      if @slot_change.save

        # @fixme
        # There must be a better way for this!
        if params[:comments] && !params[:comments][:content].empty?
          comment = Comment.new :content => params[:comments][:content]
          comment.slot_change = @slot_change
          comment.user = current_user
          unless comment.save
            logger.info "Unable to save comment #{comment.inspect} due to #{comment.errors.collect{|e| e}.inspect}"
          else
            logger.info "comment.save said true!"
          end
        end

        # @fixme
        # There must be a nicer way to do the de-normalization of quantity...
        # @wtf can't use @slot.recalculate_quantity_and_save here, if I do, it dosn't work.
        unless @slot_change.slot.recalculate_quantity_and_save
          logger.info "slot recalc FAILED #{@slot.errors.collect{|e| e}.inspect}"
        end

        format.html { redirect_to warehouse_slot_slot_changes_path(@warehouse, @slot), notice: 'slot was successfully changed.' }
      else
        format.html { render action: 'new' }
      end
    end
  end

  # GET /warehouses/:warehouse_id/slots/:slot_id/slot_changes/:id
  def show
  end

  private

    # Never trust parameters from the scary internet, only allow the white list through.
    def slot_change_params
      params.require(:slot_change).permit(:slot_id, :warehouse_id, :quantity)
    end
end
