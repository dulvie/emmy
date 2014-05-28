class PurchasesController < ApplicationController

  load_and_authorize_resource

  before_filter :new_breadcrumbs, only: [:new, :create]
  before_filter :show_breadcrumbs, only: [:show, :update]

  def create
    @purchase = Purchase.new purchase_params
    @purchase.user = current_user
    respond_to do |format|
      if @purchase.save
        format.html { redirect_to purchase_path(@purchase), notice: "#{t(:purchase)} #{t(:was_successfully_created)}" }
      else
        flash.now[:danger] = "#{t(:failed_to_create)} #{t(:purchase)}"
        format.html { render action: :new }
        #format.json { render json: @sale.errors, status: :unprocessable_entity }
      end
    end
  end

  def new
  end

  def update
    respond_to do |format|
      if @purchase.update(purchase_params)
        format.html { redirect_to purchase_path(@purchase), notice: 'supplier was successfully updated.' }
        #format.json { head :no_content }
      else
        flash.now[:danger] = "#{t(:failed_to_update)} #{t(:purchase)}"
        format.html { render action: 'edit' }
        #format.json { render json: @supplier.errors, status: :unprocessable_entity }
      end
    end
  end
  
  def edit
  end

  def index
    @breadcrumbs = [[t(:purchases)]]
    @purchases = @purchases.collect{|purchase| purchase.decorate}
  end

  def show
  end

  def destroy
    @purchase.destroy
    respond_to do |format|
      format.html { redirect_to purchase_path, notice: "#{t(:purchase)} #{t(:was_successfully_deleted)}" }
      #format.json { head :no_content }
    end
  end
 
  def state_change
    @purchase = Purchase.find(params[:id])
    if @purchase.state_change(params[:new_state])
      @purchase.update(purchase_params)
      msg = t(:success)
    else
      msg = t(:fail)
    end
    respond_to do |format|
      format.html { redirect_to purchase_path(@purchase), notice: msg}
    end
  end

  private

    def purchase_params
      params.require(:purchase).permit(Purchase.accessible_attributes.to_a)
    end

    def new_breadcrumbs
      @breadcrumbs = [[t(:purchases), purchases_path], ["#{t(:new)} #{t(:purchase)}"]]
    end

    def show_breadcrumbs
      @breadcrumbs = [[t(:purchases), purchases_path], ["##{@purchase.id}"]]
    end 
end
