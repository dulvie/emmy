class Api::SalesController < ApplicationController

  http_basic_authenticate_with :name => "myfinance", :password => "credit123"
  skip_before_filter :authenticate_user!
  skip_before_action :verify_authenticity_token
  skip_authorization_check

  def create
    @sale = Sale.new sale_params
    @sale.user = User.find(params[:sale][:user_id])
    respond_to do |format|
      if @sale.save
        items = params[:sale][:sale_items]
        items.each do |item|
          @sale_item = @sale.sale_items.build item
          @sale_item.save
        end
        format.json { render json: @sale.id, status: :created }
      else
        format.json { render json: @sale.errors, status: :unprocessable_entity }
      end
    end
  end

  private
    def sale_params
      params.require(:sale).permit(Sale.accessible_attributes.to_a)
    end
end
