class CustomersController < ApplicationController
  respond_to :html, :json
  load_and_authorize_resource

  before_filter :new_breadcrumbs, only: [:new, :create]
  before_filter :show_breadcrumbs, only: [:show, :update]
  before_filter :load_contats, only: [:show, :new, :edit, :create, :update]

  def name_search
    @breadcrumbs = [['Customers'],['name_search']]
    name = "%#{params[:name]}%"
    @customers = Customer.where("name ILIKE ?", name).order("name").page(params[:page]).per(8)
    render :index
  end

  # GET /customers
  # GET /customers.json
  def index
    respond_to do |format|
    	@breadcrumbs = [['Customers']]
     	format.html {@customers = Customer.order("name").page(params[:page]).per(8)}
    	format.json {render json: @customers}
    end	
  end

  # GET /customers/new
  def new
  end

  # GET /customers/1
  def show
  end

  # POST /customers
  # POST /customers.json
  def create
    @customer = Customer.new(customer_params)
    @customer.organisation = current_organisation
    respond_to do |format|
      if @customer.save
        format.html { redirect_to customers_url, notice: 'customer was successfully created.' }
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
        format.html { redirect_to customers_url, notice: 'customer was successfully updated.' }
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

    def load_contats
      @contacts = ContactRelation.where('parent_type = ? and parent_id = ?', 'Customer', @customer)
    end
end
