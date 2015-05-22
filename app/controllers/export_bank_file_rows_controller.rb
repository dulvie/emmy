class ExportBankFileRowsController < ApplicationController
  respond_to :html, :json
  load_and_authorize_resource :export_bank_file_row, through: :current_organization

  before_filter :show_breadcrumbs, only: [:edit, :show, :update]

  # GET
  def index
    @breadcrumbs = [['export_bank_file_row']]
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
    @export_bank_file = @export_bank_file_row.export_bank_file
    respond_to do |format|
      if @export_bank_file_row.update(export_bank_file_row_params)
        format.html { redirect_to export_bank_file_path(@export_bank_file), notice:  "#{t(:export_bank_file_row)} #{t(:was_successfully_updated)}" }
      else
        flash.now[:danger] = "#{t(:failed_to_update)} #{t(:export_bank_file_row)}"
        format.html { render action: 'show' }
      end
    end
  end

  # DELETE
  def destroy
    @export_bank_file = @export_bank_file_row.export_bank_file
    @export_bank_file_row.destroy
    respond_to do |format|
      format.html { redirect_to export_bank_file_path(@export_bank_file), notice:  "#{t(:export_bank_file_row)} #{t(:was_successfully_deleted)}" }
    end
  end

  private

  # Never trust parameters from the scary internet, only allow the white list through.
  def export_bank_file_row_params
    params.require(:export_bank_file_row).permit(ExportBankFileRow.accessible_attributes.to_a)
  end

  def show_breadcrumbs
   @export_bank_file = @export_bank_file_row.export_bank_file
   @breadcrumbs = [["#{t(:export_bank_file)}", export_bank_file_path(@export_bank_file)], [@export_bank_file_row.name]]
  end
end
