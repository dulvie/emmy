class StockValueItemsController < ApplicationController
  respond_to :html, :json
  load_and_authorize_resource :stock_value, through: :current_organization
  load_and_authorize_resource :stock_value_item, through: :current_organization

  before_filter :new_breadcrumbs, only: [:new, :create]
  before_filter :show_breadcrumbs, only: [:edit, :show, :update]

  # GET
  def index
    @breadcrumbs = [[t(:stock_values), stock_values_path], [@stock_value.name, stock_value_path(@stock_value)]]
    @stock_value_items = @stock_value_items.where('stock_value_id = ?', @stock_value).page(params[:page])
  end

  # GET
  def new
  end

  # GET
  def show
  end

  # GET
  def edit
  end

  # POST
  def create
    @stock_value = current_organization.stock_values.find(params[:stock_value_id])
    @stock_value_item = @stock_value.stock_value_items.build stock_value_item_params
    @stock_value_item.organization = current_organization
    respond_to do |format|
      if @stock_value_item.save
        recalculate(@stock_value_item.stock_value)
        format.html { redirect_to stock_value_stock_value_items_path(@stock_value), notice: "#{t(:stock_value_item)} #{t(:was_successfully_created)}" }
      else
        flash.now[:danger] = "#{t(:failed_to_create)} #{t(:stock_value_item)}"
        format.html { render action: 'new' }
      end
    end
  end

  # PATCH/PUT
  def update
    respond_to do |format|
      if @stock_value_item.update(stock_value_item_params)
        recalculate(@stock_value_item.stock_value)
        format.html { redirect_to stock_value_stock_value_items_path(@stock_value), notice: "#{t(:stock_value_item)} #{t(:was_successfully_updated)}" }
      else
        flash.now[:danger] = "#{t(:failed_to_update)} #{t(:stock_value_item)}"
        format.html { render action: 'show' }
      end
    end
  end

  # DELETE
  def destroy
    @stock_value_item.destroy
    respond_to do |format|
      recalculate(@stock_value_item.stock_value)
      format.html { redirect_to  stock_value_stock_value_items_path(@stock_value), notice:  "#{t(:stock_value_item)} #{t(:was_successfully_deleted)}" }
    end
  end

  private

  # Never trust parameters from the scary internet, only allow the white list through.
  def stock_value_item_params
    params.require(:stock_value_item).permit(StockValueItem.accessible_attributes.to_a)
  end

  def new_breadcrumbs
    @breadcrumbs = [[t(:stock_values), stock_values_path], [@stock_value.name, stock_value_path(@stock_value)], ["#{t(:new)} #{t(:stock_value_item)}"]]
  end

  def show_breadcrumbs
    @breadcrumbs = [[t(:stock_values), stock_values_path], [@stock_value.name, stock_value_path(@stock_value)], [@stock_value_item.name]]
  end
  
  def recalculate(stock_value)
    @stock_value_creator = Services::StockValueCreator.new(current_organization, current_user, stock_value)
    @stock_value_creator.recalculate
  end
end
