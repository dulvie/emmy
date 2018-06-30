class SimplifiedSalesController < ApplicationController
  #load_and_authorize_resource :production, through: :current_organization
  before_filter :new_breadcrumbs, only: [:new, :create]

  respond_to :html

  def new
    @import_bank_file_row = current_organization.import_bank_file_rows.find(params[:import_bank_file_row_id])
    @simplified_sale = SimplifiedSale.new
    @simplified_sale.import_bank_file_row_id = @import_bank_file_row.id
    @simplified_sale.posting_date = @import_bank_file_row.posting_date
    @simplified_sale.price = @import_bank_file_row.amount
    @simplified_sale = @simplified_sale.decorate
    init_form
  end

  def show
  end

  def create
    @simplified_sale = SimplifiedSale.new(simplified_sale_params)
    @simplified_sale.organization_id = current_organization.id
    respond_to do |format|
      if @simplified_sale.submit
        format.html { redirect_to verificate_path(@simplified_sale.verificate_id),
                                  notice: 'simplified sale was successfully created.' }
      else
        flash.now[:danger] = "#{t(:failed_to_add)} #{t(:simplified_sale)}"
        init_form
        format.html { render action: 'new' }
      end
    end
  end


  private

  def simplified_sale_params
    params.require(:simplified_sale).permit(:warehouse_id, :customer_id, :contact_name, :posting_date,
                                            :our_reference_id, :invoice_text, :name, :price, :quantity,
                                            :result_unit_id, :import_bank_file_row_id)
  end

  def init_form
    @warehouses = current_organization.warehouses
    @customers = current_organization.customers
    @users = current_organization.users
    @result_units = current_organization.result_units
    @invoice_text = SimplifiedSale::INVOICE_TEXT
  end

  def new_breadcrumbs
    @breadcrumbs = [
                    ["#{t(:new)} #{t(:simplified_sale)}"]]
  end
end
