class Api::ProductsController < ApplicationController

  http_basic_authenticate_with :name => "myfinance", :password => "credit123"
  skip_before_filter :authenticate_user!
  skip_before_action :verify_authenticity_token
  skip_authorization_check

  def create
    @product = Product.new(product_params)
    respond_to do |format|
      if @product.save
        format.json { render json: @product.id, status: :created }
       else
        format.json { render json: @product.errors, status: :unprocessable_entity }
      end
    end
  end

  private
    def product_params
      params.require(:product).permit(Product.accessible_attributes.to_a)
    end
end