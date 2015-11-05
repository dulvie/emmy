class ImportBatchesController < ApplicationController
  skip_authorization_check
  before_filter :load_import
  before_filter :new_breadcrumbs, only: [:new, :create]

  respond_to :html

  def new
    @import_batch = ImportBatch.new
    @import_batch.description = 'Import'
    @import_batch.import_id = @import.id
    init_new
  end

  def create
    @import_batch = ImportBatch.new(import_batch_params)
    @import_batch.organization_id = current_organization.id
    respond_to do |format|
      if @import_batch.submit
        format.html { redirect_to edit_import_path(@import_batch.import_id), notice: 'batch was successfully created.' }
      else
        @import_batch.import_id = @import.id
        init_new
        format.html { render action: 'new' }
      end
    end
  end

  private

  def init_new
    @items = current_organization.items.where("stocked=? and item_type IN('both', 'purchase')", 'true')
    message = "#{I18n.t(:items)} #{I18n.t(:missing)}" if @items.size == 0
    @suppliers = current_organization.suppliers
    message = "#{I18n.t(:suppliers)} #{I18n.t(:missing)}" if @suppliers.size == 0
    gon.push suppliers: ActiveModel::ArraySerializer.new(@suppliers, each_serializer: SupplierSerializer), items: ActiveModel::ArraySerializer.new(@items, each_serializer: ItemSerializer)
    redirect_to helps_show_message_path(message:message) if @items.size == 0 || @suppliers.size == 0
  end

  def load_import
    @import = current_organization.imports.find(params[:import_id])
  end

  def import_batch_params
    params.require(:import_batch).permit(:import_id, :item_id, :name, :description, :supplier, :contact_name, :contact_email, :quantity, :price)
  end

  def new_breadcrumbs
    @breadcrumbs = [['Imports', imports_path], [@import.description, import_path(params['import_id'])], ["#{t(:new)} #{t(:import_batch)}"]]
  end
end
