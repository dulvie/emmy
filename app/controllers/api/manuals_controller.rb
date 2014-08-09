class Api::ManualsController < ApplicationController

  http_basic_authenticate_with :name => "myfinance", :password => "credit123"
  skip_before_filter :authenticate_user!
  skip_before_action :verify_authenticity_token
  skip_authorization_check

  def create
    warehouse = Warehouse.find(params[:manual][:warehouse_id])
    product = Product.find(params[:manual][:product_id])

    product_transaction = ProductTransaction.new(
      warehouse: warehouse,
      product: product,
      quantity: params[:manual][:quantity])

    @manual = Manual.new(manual_params)
    @manual.comments.build(user_id: 1, body: params[:manual][:comment])
    @manual.product_transaction = product_transaction

    respond_to do |format|
      if @manual.save
        format.json { render json: @manual.id, status: :created }
       else
        format.json { render json: @manual.errors, status: :unprocessable_entity }
      end
    end
  end

  private
    def manual_params
      params.require(:manual).permit(Manual.accessible_attributes.to_a)
    end
end
