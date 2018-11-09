class TaxTablesController < ApplicationController
  respond_to :html, :json
  load_and_authorize_resource through: :current_organization

  before_action :new_breadcrumbs, only: [:new, :create]
  before_action :show_breadcrumbs, only: [:edit, :show, :update]

  # GET /tax_tables
  # GET /tax_tables.json
  def index
    @breadcrumbs = [[t(:tax_tables)]]
    @tax_tables = current_organization.tax_tables.order(:name)
    @tax_tables = @tax_tables.page(params[:page])
    @tax_table = current_organization.tax_tables
        .order('created_at DESC').first
  end

  # GET /tax_tables/new
  def new
    init_form
  end

  # GET /tax_tables/1
  def show
    init_form
  end

  # GET /tax_table/1/edit
  def edit
    init_form
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
        init_form
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
        init_form
        format.html { render action: 'show' }
      end
    end
  end

  # DELETE /tax_tables/1
  # DELETE /tax_tables/1.json
  def destroy
    @tax_table.background_destroy
    respond_to do |format|
      format.html { redirect_to tax_tables_url, notice: 'tax tax table was successfully deleted.' }
    end
  end

  private

  # Never trust parameters from the scary internet, only allow the white list through.
  def tax_table_params
    params.require(:tax_table).permit(:name, :file_name, :year, :table_name)
  end

  def new_breadcrumbs
    @breadcrumbs = [[t(:tax_tables), tax_tables_path], ["#{t(:new)} #{t(:tax_table)}"]]
  end

  def show_breadcrumbs
    @breadcrumbs = [[t(:tax_tables), tax_tables_path], [@tax_table.name]]
  end

  def init_form
    @tax_tables = current_organization.tax_tables
    @file_importer = FileImporter.new(TaxTable::DIRECTORY, @tax_tables, nil)
    @files = @file_importer.files(TaxTable::FILES)
  end
end
