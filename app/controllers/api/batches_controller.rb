class Api::BatchesController < ApplicationController

  http_basic_authenticate_with :name => "myfinance", :password => "credit123"
  skip_before_filter :authenticate_user!
  skip_before_action :verify_authenticity_token
  skip_authorization_check

  def create
    @batch = Batch.new(batch_params)
    @batch.organization_id =  params[:batch][:organization_id]
    respond_to do |format|
      if @batch.save
        format.json { render json: @batch.id, status: :created }
       else
        format.json { render json: @batch.errors, status: :unprocessable_entity }
      end
    end
  end

  private
    def batch_params
      params.require(:batch).permit(Batch.accessible_attributes.to_a)
    end
end