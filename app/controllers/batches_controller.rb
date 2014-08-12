class BatchesController < ApplicationController

  respond_to :html, :json
  load_and_authorize_resource

  before_filter :new_breadcrumbs, only: [:new, :create]
  before_filter :edit_breadcrumbs, only: [:show, :edit, :update]

  # GET /batches
  # GET /batches.json
  def index
    @breadcrumbs = [['Batches']]
    batches = @batches.order(:name).collect{|batch| batch.decorate}
    @batches = Kaminari.paginate_array(batches).page(params[:page]).per(8)
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
  # POST /batches.json
  def create
    @batch = Batch.new(batch_params)

    respond_to do |format|
      if @batch.save
        logger.info "batch param: #{params.inspect}"
        obj_id = params[:object]
        if params[:class]=='Production'
          production = Production.find(obj_id)
          production.batch = @batch
          production.save
          format.html { redirect_to edit_production_path(obj_id), notice: 'batch was successfully created.'}
        elsif params[:class]=='Import'
          production = Import.find(obj_id)
          production.batch = @batch
          production.save
          format.html { redirect_to edit_import_path(obj_id), notice: 'batch was successfully created.'}
        else
          format.html { redirect_to batches_path, notice: 'batch was successfully created.' }
          #format.json { render action: 'show', status: :created, location: @batch }
        end
      else
        flash.now[:danger] = "#{t(:failed_to_create)} #{t(:batch)}"
        init_new
        format.html { render action: 'new' }
        #format.json { render json: @batch.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /batches/1
  # PATCH/PUT /batches/1.json
  def update
    respond_to do |format|
      if @batch.update(batch_params)
        format.html { redirect_to batches_path, notice: 'batch was successfully updated.' }
        #format.json { head :no_content }
      else
        flash.now[:danger] = "#{t(:failed_to_update)} #{t(:batch)}"
        init_new
        format.html { render action: 'edit' }
        #format.json { render json: @batch.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /batches/1
  # DELETE /batches/1.json
  def destroy
    @batch.destroy
    respond_to do |format|
      format.html { redirect_to batches_url, notice: 'batch was successfully deleted.' }
      #format.json { head :no_content }
    end
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
      if params[:class]=='Production'
        @breadcrumbs = [['Productions', productions_path], [Production.find(obj_id).description, production_path(obj_id)], ["#{t(:new)} #{t(:batch)}"]]
      elsif params[:class]=='Import'
        @breadcrumbs = [['Imports', imports_path], [Import.find(obj_id).description, import_path(obj_id)], ["#{t(:new)} #{t(:batch)}"]]
      else
        @breadcrumbs = [['Batches', batches_path], ["#{t(:new)} #{t(:batch)}"]]
      end
    end

    def edit_breadcrumbs
      @breadcrumbs = [['Batches', batches_path], [@batch.name]]
    end
end
