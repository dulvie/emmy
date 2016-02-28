class ItemsController < ApplicationController
  respond_to :html, :json

  load_and_authorize_resource through: :current_organization
  before_filter :new_breadcrumbs, only: [:new, :create]
  before_filter :edit_breadcrumbs, only: [:edit, :update, :show]

  # GET /items
  # GET /items.json
  def index
    @breadcrumbs = [['Items']]
    @items = @items.order(:name).page(params[:page])
  end

  # GET /items/1
  # GET /items/1.json
  def show
    respond_with @item
  end

  # GET /items/new
  def new
    init_collection
  end

  # GET /items/1/edit
  def edit
    init_collection
  end

  # POST /items
  # POST /items.json
  def create
    @item = Item.new(item_params)
    @item.organization = current_organization
    respond_to do |format|
      if @item.save
        format.html { redirect_to items_path, notice: 'item was successfully created.' }
        # format.json { render action: 'show', status: :created, location: @item }
      else
        flash.now[:danger] = "#{t(:failed_to_create)} #{t(:item)}"
        init_collection
        format.html { render action: 'new' }
        # format.json { render json: @item.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /items/1
  # PATCH/PUT /items/1.json
  def update
    respond_to do |format|
      if @item.update(item_params)
        format.html { redirect_to items_path, notice: "#{t(:item)} #{t(:was_successfully_updated)}" }
        # format.json { head :no_content }
      else
        flash.now[:danger] = "#{t(:failed_to_update)} #{t(:item)}"
        init_collection
        format.html { render action: 'edit' }
        # format.json { render json: @item.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /items/1
  # DELETE /items/1.json
  def destroy
    @item.destroy
    respond_to do |format|
      format.html { redirect_to items_url, notice: "#{t(:item)} #{t(:was_successfully_deleted)}" }
      # format.json { head :no_content }
    end
  end

  private

  # Never trust parameters from the scary internet, only allow the white list through.
  def item_params
    params.require(:item).permit(Item.accessible_attributes.to_a)
  end

  def new_breadcrumbs
    @breadcrumbs = [['items', items_path], ["#{t(:new)} #{t(:item)}"]]
  end

  def edit_breadcrumbs
    @breadcrumbs = [['items', items_path], [@item.name]]
  end

  def init_collection
    @units = current_organization.units
    message = "#{I18n.t(:units)} #{I18n.t(:missing)}" if @units.size == 0
    @vats = current_organization.vats
    message = "#{I18n.t(:vats)} #{I18n.t(:missing)}" if @vats.size == 0
    redirect_to helps_show_message_path(message:message) if @units.size == 0 || @vats.size == 0
  end
end
