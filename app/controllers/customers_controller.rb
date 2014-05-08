class CustomersController < ApplicationController
  load_and_authorize_resource

  # GET /customers
  # GET /customers.json
  def index
    @breadcrumbs = [['Customers']]
  end

  # GET /customers/1
  # GET /customers/1.json
  def show
    @breadcrumbs = [['Customers', customers_path], [@customer.name]]
  end

  # GET /customers/new
  def new
    @breadcrumbs = [['Customers', customers_path], ['New customer']]
  end

  # GET /customers/1/edit
  def edit
    @breadcrumbs = [['Customers', customers_path], [@customer.name]]
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
end
