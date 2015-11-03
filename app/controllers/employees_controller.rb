class EmployeesController < ApplicationController
  respond_to :html, :json
  load_and_authorize_resource through: :current_organization

  before_filter :new_breadcrumbs, only: [:new, :create]
  before_filter :show_breadcrumbs, only: [:edit, :show, :update]
  before_filter :load_dependent, only: [:new, :show, :edit]


  # GET
  def index
    @breadcrumbs = [["#{t(:employees)}"]]
    init
  end

  # GET
  def new
  end

  # GET
  def show
    if @employee.contact.nil?
      @new = true
      @employee.contact_relation = ContactRelation.new
      @employee.contact = Contact.new
      @contact_relation = @employee.contact_relation
      @contact = @employee.contact
      @contact_relation_form_url = contact_relations_path(parent_type: @contact_relation.parent_type, parent_id: @contact_relation.parent_id)
    else
      @new = false
      @contact_relation = @employee.contact_relation
      @contact = @employee.contact
      @contact_relation_form_url = contact_relation_path(@contact_relation.id, parent_type: @contact_relation.parent_type, parent_id: @contact_relation.parent_id)
    end

    @contacts = current_organization.contacts
    gon.push contacts: ActiveModel::ArraySerializer.new(@contacts, each_serializer: ContactSerializer)
  end

  # GET
  def edit
  end

  # POST
  def create
    @employee = Employee.new(employee_params)
    @employee.organization = current_organization
    respond_to do |format|
      if @employee.save
        format.html { redirect_to employees_url, notice: "#{t(:employee)} #{t(:was_successfully_created)}" }
      else
        flash.now[:danger] = "#{t(:failed_to_create)} #{t(:employee)}"
        @tax_tables = current_organization.tax_tables.order(:name)
        format.html { render action: 'new' }
      end
    end
  end

  # PATCH/PUT
  def update
    respond_to do |format|
      if @employee.update(employee_params)
        format.html { redirect_to employees_url, notice: "#{t(:employee)} #{t(:was_successfully_updated)}" }
      else
        flash.now[:danger] = "#{t(:failed_to_update)} #{t(:employee)}"
        @tax_tables = current_organization.tax_tables.order(:name)
        format.html { render action: 'show' }
      end
    end
  end

  # DELETE
  def destroy
    @employee.destroy
    respond_to do |format|
      format.html { redirect_to employees_url, notice: "#{t(:employee)} #{t(:was_successfully_deleted)}" }
    end
  end

  private

  # Never trust parameters from the scary internet, only allow the white list through.
  def employee_params
    params.require(:employee).permit(Employee.accessible_attributes.to_a)
  end

  def new_breadcrumbs
    @breadcrumbs = [["#{t(:employee)}", employees_path], ["#{t(:new)} #{t(:employee)}"]]
  end

  def show_breadcrumbs
    @breadcrumbs = [["#{t(:employee)}", employees_path], [@employee.name]]
  end

  def init
    @employees = current_organization.employees.order(:name)
    @employees = @employees.page(params[:page]).decorate
  end

  def load_dependent
    @tax_tables = current_organization.tax_tables.order(:name)
    if @tax_tables.size == 0
      redirect_to helps_show_message_path(message:"#{I18n.t(:tax_tables)} #{I18n.t(:missing)}")
    end
  end
end
