class CustomersController < ApplicationController
  respond_to :html, :json
  load_and_authorize_resource

  before_filter :new_breadcrumbs, only: [:new, :create]
  before_filter :show_breadcrumbs, only: [:show, :update]

  # GET /customers
  # GET /customers.json
  def index
    @breadcrumbs = [['Customers']]
    @customers = Customer.paginate :page => params[:page], :per_page => 5
  end

  # GET /customers/new
  def new
  end

  # GET /customers/1
  def show
    respond_with @customer
  end

  # POST /customers
  # POST /customers.json
  def create
    @customer = Customer.new(customer_params)

    respond_to do |format|
      if @customer.save
        format.html { redirect_to @customer, notice: 'customer was successfully created.' }
        #format.json { render action: 'show', status: :created, location: @customer }
      else
        flash.now[:danger] = "#{t(:failed_to_create)} #{t(:customer)}"
        format.html { render action: 'new' }
        #format.json { render json: @customer.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /customers/1
  # PATCH/PUT /customers/1.json
  def update
    respond_to do |format|
      if @customer.update(customer_params)
        format.html { redirect_to @customer, notice: 'customer was successfully updated.' }
        #format.json { head :no_content }
      else
        flash.now[:danger] = "#{t(:failed_to_update)} #{t(:customer)}"
        format.html { render action: 'show' }
        #format.json { render json: @customer.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /customers/1
  # DELETE /customers/1.json
  def destroy
    @customer.destroy
    respond_to do |format|
      format.html { redirect_to customers_url, notice: 'Customer was successfully deleted.' }
      #format.json { head :no_content }
    end
  end

  private

    # Never trust parameters from the scary internet, only allow the white list through.
    def customer_params
      params.require(:customer).permit(Customer.accessible_attributes.to_a)
    end

    def new_breadcrumbs
      @breadcrumbs = [['Customers', customers_path], ["#{t(:new)} #{t(:customer)}"]]
    end

    def show_breadcrumbs
      @breadcrumbs = [['Customers', customers_path], [@customer.name]]
    end
end
