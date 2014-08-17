class ProductionsController < ApplicationController

  load_and_authorize_resource

  before_filter :new_breadcrumbs, only: [:new, :create]
  before_filter :edit_breadcrumbs, only: [:show, :edit, :update]

  # GET /productions
  # GET /productions.json
  def index
    @breadcrumbs = [[t(:productions)]]
    logger.info "Params:  #{params[:state]}"
    if params[:state] == 'not_started'
      productions = @productions.where("state = ?", 'not_started').collect{|production| production.decorate}
    elsif params[:state] == "started"

      productions = @productions.where("state = ?", 'started').collect{|production| production.decorate}
    else
      logger.info "Params:  #{params[:state]}"
      productions = @productions.order(:started_at).collect{|production| production.decorate}
    end

    @productions = Kaminari.paginate_array(productions).page(params[:page]).per(8)
  end

  # GET /productions/1
  # GET /productions/1.json
  def show
    @pdummy = @production
    render 'edit'
  end

  # GET /productions/new
  def new
    @costitems_size = 0
    @materials_size = 0
    @production.our_reference = current_user
  end

  # GET /productions/1/edit
  def edit    
  end

  # POST /productions
  # POST /productions.json
  def create
    @production = Production.new(production_params)
    respond_to do |format|
      if @production.save
        format.html { redirect_to edit_production_path(@production), notice: 'production was successfully created.'}
      else
        flash.now[:danger] = "#{t(:failed_to_create)} #{t(:import)}"
        format.html { render action: 'new' }
      end
    end    
  end

  def update
    respond_to do |format|
      if @production.update_attributes(production_params)
        format.html { redirect_to edit_production_path(@production), notice: "#{t(:production)} #{t(:was_successfully_updated)}" }
      else
        flash.now[:danger] = "#{t(:failed_to_update)} #{t(:production)}"
      end
    end
  end

  def destroy
    @production.destroy
    respond_to do |format|
      format.html { redirect_to productions_path, notice: "#{t(:production)} #{t(:was_successfully_deleted)}" }
      #format.json { head :no_content }
    end
  end

  def state_change
    @production = Production.find(params[:id])
    if @production.state_change(params[:event], params[:state_change_at])
      msg = t(:success)
    else
      msg = t(:fail)
    end
    respond_to do |format|
      format.html { redirect_to edit_production_path(@production), notice: msg}
    end
  end

  private

    # Never trust parameters from the scary internet, only allow the white list through.
    def production_params
      params.require(:production).permit(Production.accessible_attributes.to_a)
    end

    def new_breadcrumbs
      @breadcrumbs = [['Productions', productions_path], ["#{t(:new)} #{t(:production)}"]]
    end

    def edit_breadcrumbs
      @breadcrumbs = [['Productions', productions_path], [@production.description]]
    end

end
