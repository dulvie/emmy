class CustomersController < ApplicationController

  respond_to :html, :json
  load_and_authorize_resource

  before_filter :new_breadcrumbs, only: [:new, :create]
  before_filter :show_breadcrumbs, only: [:show, :update]
  before_filter :load_contacts, only: [:show, :new, :edit, :create, :update]


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
    if @customer.save
      redirect_to customers_url, notice: "#{t(:customer)} #{t(:was_successfully_created)}"
    else
      flash.now[:danger] = "#{t(:failed_to_create)} #{t(:customer)}"
      render :new
    end
  end

  # PATCH/PUT /customers/1
  def update
    if @customer.update(customer_params)
      redirect_to customers_url, notice: "#{t(:customer)} #{t(:was_successfully_updated)}"
    else
      flash.now[:danger] = "#{t(:failed_to_update)} #{t(:customer)}"
      render :show
    end
  end

  # DELETE /customers/1
  def destroy
    @customer.destroy
    redirect_to customer_url, notice: "#{t(:customer)} #{t(:was_successfully_deleted)}"
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

    def load_contacts
      @contacts = @customer.contacts
    end

end
