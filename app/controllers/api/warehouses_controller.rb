class Api::WarehousesController < ApplicationController

  http_basic_authenticate_with :name => "myfinance", :password => "credit123"
  skip_before_filter :authenticate_user!
  skip_before_action :verify_authenticity_token
  skip_authorization_check

  def create
    @warehouse = Warehouse.new(warehouse_params)
    respond_to do |format|
      if @warehouse.save
        format.json { render json: @warehouse.id, status: :created }
       else
        format.json { render json: @warehouse.errors, status: :unprocessable_entity }
      end
    end
  end

  private
    def warehouse_params
      params.require(:warehouse).permit(Warehouse.accessible_attributes.to_a)
    end
end