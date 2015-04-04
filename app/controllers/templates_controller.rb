class TemplatesController < ApplicationController
  respond_to :html, :json
  load_and_authorize_resource through: :current_organization

  before_filter :new_breadcrumbs, only: [:new, :create]
  before_filter :show_breadcrumbs, only: [:edit, :show, :update]

  # GET
  def index
    init
  end

  # GET
  def new
    @accounting_plans = current_organization.accounting_plans
  end

  # GET
  def show
    @accounting_plans = current_organization.accounting_plans
  end

  # GET
  def edit
    @accounting_plans = current_organization.accounting_plans
  end

  # POST
  def create
    @template = Template.new(template_params)
    @template.organization = current_organization
    respond_to do |format|
      if @template.save
        format.html { redirect_to template_path(@template), notice: "#{t(:template)} #{t(:was_successfully_created)}" }
      else
        flash.now[:danger] = "#{t(:failed_to_create)} #{t(:template)}"
        @accounting_plans = current_organization.accounting_plans
        format.html { render action: 'new' }
      end
    end
  end

  # PATCH/PUT
  def update
    respond_to do |format|
      if @template.update(template_params)
        format.html { redirect_to templates_path, notice: "#{t(:template)} #{t(:was_successfully_updated)}" }
      else
        flash.now[:danger] = "#{t(:failed_to_update)} #{t(:template)}"
        @accounting_plans = current_organization.accounting_plans
        format.html { render action: 'show' }
      end
    end
  end

  # DELETE
  def destroy
    @template.destroy
    respond_to do |format|
      format.html { redirect_to templates_path, notice:  "#{t(:template)} #{t(:was_successfully_deleted)}" }
    end
  end

  def import
    @accounting_plan = current_organization.accounting_plans.find(params[:accounting_plan_id])
    templates = Services::TemplateCreator.new(current_organization, current_user, @accounting_plan)
    respond_to do |format|
      if templates.read_and_save
        init
        format.html {  render action: 'index', notice: "#{t(:template)} #{t(:was_successfully_imported)}" }
      else
        init
        flash.now[:danger] = "#{t(:failed_to_import)} #{t(:template)}"
        format.html { render action: 'index' }
      end
    end
  end

  private
  
  def init
    @breadcrumbs = [['Templates']]
    @accounting_plans = current_organization.accounting_plans.order('id')
    if params[:accounting_plan_id]
      plan = params[:accounting_plan_id]
      session[:accounting_plan_id] = plan
    elsif session[:accounting_plan_id]
      plan = session[:accounting_plan_id]
    else
      plan = @accounting_plans.last.id
      session[:accounting_plan_id] = plan
    end
    @plan_id = plan
    @templates = current_organization.templates.where('accounting_plan_id=?', plan).order(:name)
    @templates = @templates.page(params[:page])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def template_params
    params.require(:template).permit(Template.accessible_attributes.to_a)
  end

  def new_breadcrumbs
    @breadcrumbs = [["#{t(:templates)}", templates_path], ["#{t(:new)} #{t(:template)}"]]
  end

  def show_breadcrumbs
    @breadcrumbs = [["#{t(:templates)}", templates_path], [@template.name]]
  end
end
