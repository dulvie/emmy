# @TODO check state on update/destroy before doing anything.
class SalesController < ApplicationController
  load_and_authorize_resource

  before_filter :new_breadcrumbs, only: [:new, :create]
  before_filter :show_breadcrumbs, only: [:show, :update]

  def create
    @sale = Sale.new sale_params
    @sale.user = current_user
    respond_to do |format|
      if @sale.save
        format.html { redirect_to sale_path(@sale), notice: "#{t(:sale)} #{t(:was_successfully_created)}" }
      else
        flash.now[:danger] = "#{t(:failed_to_create)} #{t(:sale)}"
        format.html { render action: :new }
        #format.json { render json: @sale.errors, status: :unprocessable_entity }
      end
    end

  end

  def index
    @breadcrumbs = [[t(:sales)]]
    @sales = @sales.collect{|sale| sale.decorate}
  end

  def new
  end

  def show
    @sale = @sale.decorate
  end

  def update
    respond_to do |format|
      if @sale.update_attributes(sale_params)
        format.html { redirect_to sale_path(@sale), notice: "#{t(:sale)} #{t(:was_successfully_updated)}" }
      else
        flash.now[:danger] = "#{t(:failed_to_update)} #{t(:sale)}"
        format.html { render action: :show }
        #format.json { render json: @sale.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @sale.destroy
    respond_to do |format|
      format.html { redirect_to sales_path, notice: "#{t(:sale)} #{t(:was_successfully_deleted)}" }
      #format.json { head :no_content }
    end
  end

  def mark_meta_complete
    @sale = Sale.find(params[:id])
    @sale.mark_meta_complete
    respond_to do |format|
      format.html { redirect_to sales_path, notice: "#{t(:sale_marked_complete)}" }
    end
  end

  private

    def sale_params
      params.require(:sale).permit(Sale.accessible_attributes.to_a)
    end

    def new_breadcrumbs
      @breadcrumbs = [[t(:sales), sales_path], ["#{t(:new)} #{t(:sale)}"]]
    end

    def show_breadcrumbs
      @breadcrumbs = [[t(:sales), sales_path], ["##{@sale.id}"]]
    end

end