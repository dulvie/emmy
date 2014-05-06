class SuppliersController < ApplicationController
  load_and_authorize_resource

  # GET /suppliers
  # GET /suppliers.json
  def index
    @breadcrumbs = [['Suppliers']]
  end

  # GET /suppliers/1
  # GET /suppliers/1.json
  def show
    @breadcrumbs = [['Suppliers', suppliers_path], [@supplier.name]]
  end

  # GET /suppliers/new
  def new
    @breadcrumbs = [['Suppliers', suppliers_path], ['New supplier']]
  end

  # GET /suppliers/1/edit
  def edit
    @breadcrumbs = [['Suppliers', suppliers_path], [@supplier.name]]
  end

  # POST /suppliers
  # POST /suppliers.json
  def create
    @supplier = Supplier.new(supplier_params)

    respond_to do |format|
      if @supplier.save
        format.html { redirect_to edit_supplier_path(@supplier), notice: 'supplier was successfully created.' }
        #format.json { render action: 'show', status: :created, location: @supplier }
      else
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
        format.html { redirect_to edit_supplier_path(@supplier), notice: 'supplier was successfully updated.' }
        #format.json { head :no_content }
      else
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
end
