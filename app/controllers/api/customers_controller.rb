class Api::CustomersController < ApplicationController

  http_basic_authenticate_with :name => "myfinance", :password => "credit123"
  skip_before_filter :authenticate_user!
  skip_before_action :verify_authenticity_token
  skip_authorization_check

  def create
    @customer = Customer.new(customer_params)
    @customer.organization_id =  params[:customer][:organization_id]
    respond_to do |format|
      if @customer.save
        if !params[:customer][:contact].nil?
          @contact = @customer.contacts.build
          @contact.name = params[:customer][:contact]
          @contact.telephone = params[:customer][:contact_telephone]
          @contact.email = params[:customer][:contact_email]
          @contact.organization_id =  params[:customer][:organization_id]
          @contact.save
        end
        if params[:customer][:comment].length > 3
          @comment = @customer.comments.build
          @comment.body = params[:customer][:comment]
          @comment.user = User.find(1)
          @comment.organization_id =  params[:customer][:organization_id]
          @comment.save
        end
        format.json { render json: @customer.id, status: :created }
       else
        format.json { render json: @customer.errors, status: :unprocessable_entity }
      end
    end
  end

  private
    def customer_params
      params.require(:customer).permit(Customer.accessible_attributes.to_a)
    end
end