class CostitemsController < ApplicationController
  load_and_authorize_resource
  before_filter :find_and_authorize_parent

  before_filter :show_breadcrumbs, only: [:show, :update]

  def new
    @costitem = @parent.costitems.build
    @costitem_form_url = costitems_path(parent_type: @costitem.parent_type, parent_id: @costitem.parent_id)
  end

  def show
    @costitem_form_url = costitem_path(@costitem, parent_type: @costitem.parent_type, parent_id: @costitem.parent_id)
  end

  def create
    @costitem = @parent.costitems.build costitem_params
    respond_to do |format|
      if @costitem.save
        format.html { redirect_to edit_polymorphic_path(@parent), notice: "#{t(:costitem_added)}" }
      else
        flash.now[:danger] = "#{t(:failed_to_add)} #{t(:costitem)}"
        format.html { render :new }
      end
    end
  end

  def update
    respond_to do |format|
      if @costitem.update(costitem_params)
        format.html { redirect_to edit_polymorphic_path(@parent), notice: "#{t(:costitem)} #{t(:was_successfully_updated)}" }
      else
        flash.now[:danger] = "#{t(:failed_to_update)} #{t(:costitem)}"
        format.html { render :show }
      end
    end
  end

  def destroy
    @costitem.destroy
    respond_to do |format|
      format.html { redirect_to edit_polymorphic_path(@parent), notice: "#{t(:costitem)} #{t(:was_destroyed)}" }
      #format.json { head :no_content }
    end
  end


  private

    def find_and_authorize_parent

      # if costitem exists, but no parent_type, add from contact.
      unless params.has_key?(:parent_type) && @costitem
        params[:parent_type] = @costitem.parent_type
        params[:parent_id] = @costitem.parent_id
      end

      unless Costitem::VALID_PARENT_TYPES.include? params[:parent_type]
        logger.info "SECURITY: invalid parent_type(#{params[:parent_type]}) sent to #{request.original_url} "
        redirect_to '/'
        return false
      end

      parent_class = params[:parent_type].constantize
      @parent = parent_class.find(params[:parent_id])
      authorize! :manage, @parent
    end

    def costitem_params
        params.require(:costitem).permit(Costitem.accessible_attributes.to_a)
    end

    def show_breadcrumbs
      @breadcrumbs = [["#{@costitem.parent_type.pluralize}", send("#{@parent.class.name.downcase}_path")], [@costitem.parent_name, @costitem.parent], ["#{t(:costitems)}(#{@costitem.description})"]]
    end

end
