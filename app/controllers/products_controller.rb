class ProductsController < ApplicationController

  respond_to :html, :json
  load_and_authorize_resource

  before_filter :new_breadcrumbs, only: [:new, :create]
  before_filter :edit_breadcrumbs, only: [:show, :edit, :update]

  # GET /products
  # GET /products.json
  def index
    @breadcrumbs = [['Products']]
    products = @products.order(:name).collect{|product| product.decorate}
    @products = Kaminari.paginate_array(products).page(params[:page]).per(8)
    respond_with @products
  end

  # GET /products/new
  def new
    @product = Product.new
    init_new
  end

  # GET /products/1/edit
  def edit
    init_new
  end

  # POST /products
  # POST /products.json
  def create
    @product = Product.new(product_params)

    respond_to do |format|
      if @product.save
        logger.info "product param: #{params.inspect}"
        obj_id = params[:object]
        if params[:class]=='Production'
          production = Production.find(obj_id)
          production.product = @product
          production.save
          format.html { redirect_to edit_production_path(obj_id), notice: 'product was successfully created.'}
        elsif params[:class]=='Import'
          production = Import.find(obj_id)
          production.product = @product
          production.save
          format.html { redirect_to edit_import_path(obj_id), notice: 'product was successfully created.'} 
        else
          format.html { redirect_to products_path, notice: 'product was successfully created.' }
          #format.json { render action: 'show', status: :created, location: @product }
        end
      else
        flash.now[:danger] = "#{t(:failed_to_create)} #{t(:product)}"
        init_new
        format.html { render action: 'new' }
        #format.json { render json: @product.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /products/1
  # PATCH/PUT /products/1.json
  def update
    respond_to do |format|
      if @product.update(product_params)
        format.html { redirect_to products_path, notice: 'Product was successfully updated.' }
        #format.json { head :no_content }
      else
        flash.now[:danger] = "#{t(:failed_to_update)} #{t(:product)}"
        init_new
        format.html { render action: 'edit' }
        #format.json { render json: @product.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /products/1
  # DELETE /products/1.json
  def destroy
    @product.destroy
    respond_to do |format|
      format.html { redirect_to products_url, notice: 'Product was successfully deleted.' }
      #format.json { head :no_content }
    end
  end

  private
    def init_new
      @items = Item.where("stocked=?", 'true')
      gon.push items: @items 
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def product_params
      params.require(:product).permit(Product.accessible_attributes.to_a)
    end

    def new_breadcrumbs
      @breadcrumbs = [['Products', products_path], ["#{t(:new)} #{t(:product)}"]]
    end

    def edit_breadcrumbs
      @breadcrumbs = [['Products', products_path], [@product.name]]
    end
end
