class UnitsController < ApplicationController
  respond_to :html, :json

  load_and_authorize_resource through: :current_organization

  before_filter :new_breadcrumbs, only: [:new, :create]
  before_filter :show_breadcrumbs, only: [:edit, :show, :update]

  # GET /units
  # GET /units.json
  def index
    @breadcrumbs = [['Units']]
    @units = @units.order(:name).page(params[:page]).per(8)
  end

  # GET /units/new
  def new
  end

  # GET /units/1
  def show
  end

  # GET /unit/1/edit
  def edit
  end

  # POST /units
  # POST /units.json
  def create
    @unit = Unit.new(unit_params)
    @unit.organization = current_organization
    respond_to do |format|
      if @unit.save
        format.html { redirect_to units_url, notice: 'unit was successfully created.' }
      else
        flash.now[:danger] = "#{t(:failed_to_create)} #{t(:unit)}"
        format.html { render action: 'new' }
      end
    end
  end

  # PATCH/PUT /units/1
  # PATCH/PUT /units/1.json
  def update
    respond_to do |format|
      if @unit.update(unit_params)
        format.html { redirect_to units_url, notice: 'unit was successfully updated.' }
      else
        flash.now[:danger] = "#{t(:failed_to_update)} #{t(:unit)}"
        format.html { render action: 'show' }
      end
    end
  end

  # DELETE /units/1
  # DELETE /units/1.json
  def destroy
    @unit.destroy
    respond_to do |format|
      format.html { redirect_to units_url, notice: 'Unit was successfully deleted.' }
    end
  end

  private

  # Never trust parameters from the scary internet, only allow the white list through.
  def unit_params
    params.require(:unit).permit(Unit.accessible_attributes.to_a)
  end

  def new_breadcrumbs
    @breadcrumbs = [['Units', units_path], ["#{t(:new)} #{t(:unit)}"]]
  end

  def show_breadcrumbs
    @breadcrumbs = [['Units', units_path], [@unit.name]]
  end
end
