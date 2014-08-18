class ItemsController < ApplicationController

  respond_to :html, :json
  load_and_authorize_resource

  before_filter :new_breadcrumbs, only: [:new, :create]
  before_filter :edit_breadcrumbs, only: [:edit, :update]

  # GET /items
  # GET /items.json
  def index
    @breadcrumbs = [['Items']]
    @items = Item.all.order(:name).page(params[:page]).per(8)
    respond_with @items
  end

  # GET /items/1
  # GET /items/1.json
  def show
    respond_with @item
  end

  # GET /items/new
  def new
    @item = Item.new
  end

  # GET /items/1/edit
  def edit
  end

  # POST /items
  # POST /items.json
  def create
    @item = Item.new(item_params)
    @item.organisation = current_organisation
    respond_to do |format|
      if @item.save
        format.html { redirect_to items_path, notice: 'item was successfully created.' }
        #format.json { render action: 'show', status: :created, location: @item }
      else
        flash.now[:danger] = "#{t(:failed_to_create)} #{t(:item)}"
        format.html { render action: 'new' }
        #format.json { render json: @item.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /items/1
  # PATCH/PUT /items/1.json
  def update
    respond_to do |format|
      if @item.update(item_params)
        format.html { redirect_to items_path, notice: 'item was successfully updated.' }
        #format.json { head :no_content }
      else
        flash.now[:danger] = "#{t(:failed_to_update)} #{t(:item)}"
        format.html { render action: 'edit' }
        #format.json { render json: @item.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /items/1
  # DELETE /items/1.json
  def destroy
    @item.destroy
    respond_to do |format|
      format.html { redirect_to items_url, notice: 'item was successfully deleted.' }
      #format.json { head :no_content }
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
end
