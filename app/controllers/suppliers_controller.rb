class SuppliersController < ApplicationController
  load_and_authorize_resource

  before_filter :new_breadcrumbs, only: [:new, :create]
  before_filter :edit_breadcrumbs, only: [:show, :edit, :update]
  before_filter :load_contats, only: [:show, :new, :edit, :create, :update]

  # GET /suppliers
  # GET /suppliers.json
  def index
    @breadcrumbs = [['Suppliers']]
    @suppliers = Supplier.order(:name).page(params[:page]).per(8)
  end

  # GET /suppliers/1
  # GET /suppliers/1.json
  def show
    render 'edit'
  end

  # GET /suppliers/new
  def new
  end

  # GET /suppliers/1/edit
  def edit
  end

  # POST /suppliers
  # POST /suppliers.json
  def create
    @supplier = Supplier.new(supplier_params)
    @supplier.organisation = current_organisation
    respond_to do |format|
      if @supplier.save
        format.html { redirect_to suppliers_path, notice: 'supplier was successfully created.' }
        #format.json { render action: 'show', status: :created, location: @supplier }
      else
        flash.now[:danger] = "#{t(:failed_to_create)} #{t(:supplier)}"
        format.html { render action: 'new' }
        #format.json { render json: @supplier.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /suppliers/1
  # PATCH/PUT /suppliers/1.json
  def update
    respond_to do |format|
      if @supplier.update(supplier_params)
        format.html { redirect_to suppliers_path, notice: 'supplier was successfully updated.' }
        #format.json { head :no_content }
      else
        flash.now[:danger] = "#{t(:failed_to_update)} #{t(:supplier)}"       
        format.html { render action: 'edit' }
        #format.json { render json: @supplier.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /suppliers/1
  # DELETE /suppliers/1.json
  def destroy
    @supplier.destroy
    respond_to do |format|
      format.html { redirect_to suppliers_url, notice: 'Supplier was successfully deleted.' }
      #format.json { head :no_content }
    end
  end

  private

    # Never trust parameters from the scary internet, only allow the white list through.
    def supplier_params
      params.require(:supplier).permit(Supplier.accessible_attributes.to_a)
    end

    def new_breadcrumbs
      @breadcrumbs = [['Suppliers', suppliers_path], ["#{t(:new)} #{t(:supplier)}"]]
    end

    def edit_breadcrumbs
      @breadcrumbs = [['Suppliers', suppliers_path], [@supplier.name]]
    end

    def load_contats
     @contacts = @supplier.contacts
    end
end
