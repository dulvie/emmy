class TaxTablesController < ApplicationController
  respond_to :html, :json
  load_and_authorize_resource through: :current_organization

  before_filter :new_breadcrumbs, only: [:new, :create]
  before_filter :show_breadcrumbs, only: [:edit, :show, :update]

  # GET /tax_tables
  # GET /tax_tables.json
  def index
    @breadcrumbs = [["#{t(:tax_tables)}"]]
    @tax_tables = current_organization.tax_tables.order(:name)
    @tax_tables = @tax_tables.page(params[:page])
    @trans = current_organization.table_transactions.where("execute = 'tax_table'").order("created_at DESC").first
  end

  # GET /tax_tables/new
  def new
  end

  # GET /tax_tables/1
  def show
  end

  # GET /tax_table/1/edit
  def edit
  end

  # POST /tax_tables
  # POST /tax_tables.json
  def create
    @tax_table = TaxTable.new(tax_table_params)
    @tax_table.organization = current_organization
    respond_to do |format|
      if @tax_table.save
        format.html { redirect_to tax_tables_url, notice: 'tax table was successfully created.' }
      else
        flash.now[:danger] = "#{t(:failed_to_create)} #{t(:tax_table)}"
        format.html { render action: 'new' }
      end
    end
  end

  # PATCH/PUT /tax_tables/1
  # PATCH/PUT /tax_tables/1.json
  def update
    respond_to do |format|
      if @tax_table.update(tax_table_params)
        format.html { redirect_to tax_tables_url, notice: 'tax table was successfully updated.' }
      else
        flash.now[:danger] = "#{t(:failed_to_update)} #{t(:tax_table)}"
        format.html { render action: 'show' }
      end
    end
  end

  # DELETE /tax_tables/1
  # DELETE /tax_tables/1.json
  def destroy
    @tax_table.destroy
    respond_to do |format|
      format.html { redirect_to tax_tables_url, notice: 'tax tax table was successfully deleted.' }
    end
  end

  def order_import
    init_order_import
  end

  def import
    @table_trans = TableTransaction.new
    @table_trans.directory = params[:file_importer][:directory]
    @table_trans.file_name = params[:file_importer][:file]
    @table_trans.execute = 'tax_table'
    @table_trans.year = params[:file_importer][:param1]
    @table_trans.table = params[:file_importer][:param2]
    @table_trans.complete = 'false'
    @table_trans.user = current_user
    @table_trans.organization = current_organization
    respond_to do |format|    
      if @table_trans.save
        format.html { redirect_to tax_tables_url, notice: "#{t(:tax_tables)} #{t(:was_successfully_created)}" }
      else
        init_order_import
        flash.now[:danger] = "#{t(:failed_to_create)} #{t(:tax_tables)}"
        format.html { render 'order_import' }
      end
    end
  end

  private

  # Never trust parameters from the scary internet, only allow the white list through.
  def tax_table_params
    params.require(:tax_table).permit(TaxTable.accessible_attributes.to_a)
  end

  def new_breadcrumbs
    @breadcrumbs = [["#{t(:tax_tables)}", tax_tables_path], ["#{t(:new)} #{t(:tax_table)}"]]
  end

  def show_breadcrumbs
    @breadcrumbs = [["#{t(:tax_tables)}", tax_tables_path], [@tax_table.name]]
  end

  def init_order_import
    @breadcrumbs = [["#{t(:tax_tables)}", tax_tables_path], ["#{t(:order)} #{t(:import)}"]]
    from_directory = "files/codes/"
    @tax_tables = current_organization.tax_tables
    @file_importer = FileImporter.new(from_directory, @tax_tables, nil)
    @files = @file_importer.files('allm*.csv')
  end
end
