class VatsController < ApplicationController
  respond_to :html, :json
  load_and_authorize_resource through: :current_organization

  before_filter :new_breadcrumbs, only: [:new, :create]
  before_filter :show_breadcrumbs, only: [:edit, :show, :update]

  # GET /vats
  # GET /vats.json
  def index
    @breadcrumbs = [['Vats']]
    @vats = current_organization.vats.order(:name).page(params[:page])
  end

  # GET /vats/new
  def new
  end

  # GET /vats/1
  def show
  end

  # GET /vat/1/edit
  def edit
  end

  # POST /vats
  # POST /vats.json
  def create
    @vat = Vat.new(vat_params)
    @vat.organization = current_organization
    respond_to do |format|
      if @vat.save
        format.html { redirect_to vats_url, notice: 'Vat was successfully created.' }
      else
        flash.now[:danger] = "#{t(:failed_to_create)} #{t(:vat)}"
        format.html { render action: 'new' }
      end
    end
  end

  # PATCH/PUT /units/1
  # PATCH/PUT /units/1.json
  def update
    respond_to do |format|
      if @vat.update(vat_params)
        format.html { redirect_to vats_url, notice: 'Vat was successfully updated.' }
      else
        flash.now[:danger] = "#{t(:failed_to_update)} #{t(:vat)}"
        format.html { render action: 'show' }
      end
    end
  end

  # DELETE /units/1
  # DELETE /units/1.json
  def destroy
    @vat.destroy
    respond_to do |format|
      format.html { redirect_to vats_url, notice: 'Vat was successfully deleted.' }
    end
  end

  private

  # Never trust parameters from the scary internet, only allow the white list through.
  def vat_params
    params.require(:vat).permit(Vat.accessible_attributes.to_a)
  end

  def new_breadcrumbs
    @breadcrumbs = [['Vats', vats_path], ["#{t(:new)} #{t(:vat)}"]]
  end

  def show_breadcrumbs
    @breadcrumbs = [['Vats', vats_path], [@vat.name]]
  end
end
