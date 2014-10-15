class ShelvesController < ApplicationController
  load_and_authorize_resource
  def show
    @breadcrumbs = [['Warehouses', warehouses_path], [@shelf.warehouse.name, warehouse_path(@shelf.warehouse)], [@shelf.batch.name]]
    authorize! :read, @shelf.warehouse
    authorize! :read, @shelf.batch
    @batch_transactions = BatchTransaction
      .where(warehouse_id: @shelf.warehouse_id)
      .where(batch_id: @shelf.batch_id).decorate
  end
end
