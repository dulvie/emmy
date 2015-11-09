class TaxTableRowsController < ApplicationController
  respond_to :html, :json
  load_and_authorize_resource :tax_table, through: :current_organization
  load_and_authorize_resource :tax_table_row, through: :current_organization

  before_filter :show_breadcrumbs, only: [:edit, :show, :update]

  # GET
  def index
    @breadcrumbs = [[t(:tax_tables), tax_tables_path],[@tax_table.name]]
    @tax_table_rows = current_organization.tax_table_rows.where('tax_table_id=?', @tax_table.id).order(:from_wage)
    @tax_table_rows = @tax_table_rows.page(params[:page])
  end

  # GET
  def new
  end

  # GET
  def show
  end

  # GET
  def edit
  end

  # POST
  def create
  end

  # PATCH/PUT
  def update
  end

  # DELETE
  def destroy
    @tax_tanle_row.destroy
    respond_to do |format|
      format.html { redirect_to tax_table_rows_path, notice:  "#{t(:tax_table_row)} #{t(:was_successfully_deleted)}" }
    end
  end

  private

  # Never trust parameters from the scary internet, only allow the white list through.
  def tax_table_row_params
    params.require(:tex_table_row).permit(TaxTableRow.accessible_attributes.to_a)
  end

  def show_breadcrumbs
   @tax_table = @tax_table_row.tax_table
   @breadcrumbs = [[t(:tax_tables), tax_tables_path], [@tax_table.name, tax_table_tax_table_rows_path(@tax_table)], [@tax_table_row.from_wage]]
  end
end
