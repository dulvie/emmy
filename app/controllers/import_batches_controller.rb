class ImportBatchesController < ApplicationController
  skip_authorization_check
  before_filter :load_import
  before_filter :new_breadcrumbs, only: [:new, :create]

  respond_to :html

  def new
    @import_batch = ImportBatch.new
    @import_batch.import_id = @import.id
    @items = Item.where("stocked=? and item_type IN('both', 'purchase')", 'true')
    @suppliers = Supplier.all
    gon.push suppliers: ActiveModel::ArraySerializer.new(@suppliers, each_serializer: SupplierSerializer)
  end

  def create
    @import_batch = ImportBatch.new(import_batch_params)
    @import_batch.organisation_id = current_organisation.id
    respond_to do |format|
      if @import_batch.submit
        format.html { redirect_to edit_import_path(@import_batch.import_id), notice: 'batch was successfully created.'}
      else
        @import_batch.import_id = @import.id
        @items = Item.where("stocked=? and item_type IN('both', 'purchase')", 'true')
        gon.push items: @items
        format.html { render action: 'new' }
      end
    end
  end

  private
    def load_import
      @import = Import.find(params[:import_id])
    end

    def import_batch_params
      params.require(:import_batch).permit(:import_id, :item_id, :name, :description, :supplier, :contact_name, :contact_email, :quantity, :price)
    end

    def new_breadcrumbs
      @breadcrumbs = [['Imports', imports_path], [@import.description, import_path(params['import_id'])], ["#{t(:new)} #{t(:import_batch)}"]]
    end
end
