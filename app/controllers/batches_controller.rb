class BatchesController < ApplicationController

  respond_to :html, :json
  load_and_authorize_resource

  before_filter :new_breadcrumbs, only: [:new, :create]
  before_filter :edit_breadcrumbs, only: [:show, :edit, :update]


  # GET /batches
  # GET /batches.json
  def index
    @breadcrumbs = [['Batches']]
    @batches = @batches.order(:name).page(params[:page]).per(8).decorate
    respond_with @batches
  end

  # GET /batches/new
  def new
    @batch = Batch.new
    init_new
  end

  # GET /batches/1/edit
  def edit
    init_new
  end

  # POST /batches
  # @todo Refactor this into a service object.
  def create
    @batch = Batch.new(batch_params)
    @batch.organisation = current_organisation
    if @batch.save

      notice = "#{t(:batch)} #{t(:was_sucessfully_created)}"
      redir_url = batches_path
      if params[:class]=='Import'
        obj_id = params[:object]
        production = Import.find(obj_id)
        production.batch = @batch
        production.save
        redir_url = edit_import_path(obj_id)
      end
      redirect_to redir_url, notice: notice
    else
      flash.now[:danger] = "#{t(:failed_to_create)} #{t(:batch)}"
      init_new
      render action: :new
    end
  end

  # PATCH/PUT /batches/1
  def update
    if @batch.update(batch_params)
      redirect_to batches_path, notice: "#{t(:batch)} #{t(:was_successfully_updated)}"
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
      @items = Item.where("stocked=?", 'true')
      gon.push items: @items
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def batch_params
      params.require(:batch).permit(Batch.accessible_attributes.to_a)
    end

    def new_breadcrumbs
      obj_id = params[:object]
      if params[:class]=='Import'
        @breadcrumbs = [['Imports', imports_path], [Import.find(obj_id).description, import_path(obj_id)], ["#{t(:new)} #{t(:batch)}"]]
      else
        @breadcrumbs = [['Batches', batches_path], ["#{t(:new)} #{t(:batch)}"]]
      end
    end

    def edit_breadcrumbs
      @breadcrumbs = [['Batches', batches_path], [@batch.name]]
    end

end
