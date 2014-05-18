class CustomersController < ApplicationController
  respond_to :html, :json
  load_and_authorize_resource

  before_filter :new_breadcrumbs, only: [:new, :create]
  before_filter :edit_breadcrumbs, only: [:edit, :update]

  # GET /customers
  # GET /customers.json
  def index
    @breadcrumbs = [['Customers']]
    respond_with @customers
  end

  # GET /customers/1
  # GET /customers/1.json
  def show
    @breadcrumbs = [['Customers', customers_path], [@customer.name]]
    respond_with @customer
  end

  # GET /customers/new
  def new
  end

  # GET /customers/1/edit
  def edit
  end

  # POST /customers
  # POST /customers.json
  def create
    @customer = Customer.new(customer_params)

    respond_to do |format|
      if @customer.save
        format.html { redirect_to edit_customer_path(@customer), notice: 'customer was successfully created.' }
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
        format.html { redirect_to edit_customer_path(@customer), notice: 'customer was successfully updated.' }
        #format.json { head :no_content }
      else
        flash.now[:danger] = "#{t(:failed_to_update)} #{t(:customer)}"
        format.html { render action: 'edit' }
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

    def edit_breadcrumbs
      @breadcrumbs = [['Customers', customers_path], [@customer.name]]
    end
end
