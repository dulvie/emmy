class BatchesController < ApplicationController
  respond_to :html, :json

  load_and_authorize_resource  through: :current_organization
  before_action :new_breadcrumbs, only: [:new, :create]
  before_action :edit_breadcrumbs, only: [:show, :edit, :update]

  # GET /batches
  # GET /batches.json
  def index
    @breadcrumbs = [['Batches']]
    @batches = @batches.order(:name).page(params[:page]).decorate
  end

  # GET /batches/new
  def new
    @batch = Batch.new
    init_new
  end

  # GET /batches/1/edit
  def edit
    init_new
    @production = current_organization.productions.where('batch_id = ?', @batch.id).first
  end

  # GET /batches/1
  def show
    init_new
    @production = current_organization.productions.where('batch_id = ?', @batch.id).first
  end

  # POST /batches
  def create
    @batch = Batch.new(batch_params)
    @batch.organization = current_organization
    if @batch.save
      notice = "#{t(:batch)} #{t(:was_successfully_created)}"
      redirect_to batches_path, notice: notice
    else
      flash.now[:danger] = "#{t(:failed_to_create)} #{t(:batch)}"
      init_new
      render action: :new
    end
  end

  # PATCH/PUT /batches/1
  def update
    if @batch.update(batch_params)
      url = batches_path
      url = edit_production_path(params[:return_path]) if !params[:return_path].blank?
      redirect_to url, notice: "#{t(:batch)} #{t(:was_successfully_updated)}"
    else
      flash.now[:danger] = "#{t(:failed_to_update)} #{t(:batch)}"
      init_new
      render :edit
    end
  end

  # DELETE /batches/1
  # DELETE /batches/1.json
  def destroy
    @batch.destroy
    redirect_to batches_url, notice: "#{t(:batch)} #{t(:was_successfully_deleted)}"
  end

  private

  def init_new
    @items = current_organization.items.where('stocked=?', 'true')
    redirect_to helps_show_message_path(message: "#{I18n.t(:items)} #{I18n.t(:missing)}") if @items.size == 0
    gon.push items: ActiveModel::ArraySerializer.new(@items, each_serializer: ItemSerializer)
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def batch_params
    params.require(:batch).permit(:item_id, :name, :comment, :in_price, :distributor_price, :retail_price, :expire_at, :refined_at)
  end

  def new_breadcrumbs
    obj_id = params[:object]
    if params[:class] == 'Import'
      @breadcrumbs = [['Imports', imports_path], [Import.find(obj_id).description, import_path(obj_id)], ["#{t(:new)} #{t(:batch)}"]]
    else
      @breadcrumbs = [['Batches', batches_path], ["#{t(:new)} #{t(:batch)}"]]
    end
  end

  def edit_breadcrumbs
    @breadcrumbs = [['Batches', batches_path], [@batch.name]]
  end
end
