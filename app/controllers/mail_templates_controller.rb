class MailTemplatesController < ApplicationController
  respond_to :html, :json
  load_and_authorize_resource through: :current_organization

  before_action :new_breadcrumbs, only: [:new, :create]
  before_action :show_breadcrumbs, only: [:edit, :show, :update]

  # GET
  def index
    @breadcrumbs = [[t(:mail_templates)]]
    @current_organization = current_organization
    @mail_templates = current_organization.mail_templates
    @mail_templates = @mail_templates.page(params[:page])
  end

  # GET
  def new
    set_default
    set_variable
  end

  # GET
  def show
  end

  # GET
  def edit
  end

  # POST
  def create
    @mail_template = MailTemplate.new(mail_template_params)
    @mail_template.organization = current_organization
    respond_to do |format|
      set_default
      if @mail_template.save
        format.html { redirect_to mail_templates_path, notice: "#{t(:mail_template)} #{t(:was_successfully_created)}" }
      else
        flash.now[:danger] = "#{t(:failed_to_create)} #{t(:mail_template)}"
        format.html { render action: 'new' }
      end
    end
  end

  # PATCH/PUT
  def update
    respond_to do |format|
      if @mail_template.update(mail_template_params)
        format.html { redirect_to mail_templates_path, notice: "#{t(:mail_template)} #{t(:was_successfully_updated)}" }
      else
        flash.now[:danger] = "#{t(:failed_to_update)} #{t(:mail_template)}"
        format.html { render action: 'show' }
      end
    end
  end

  # DELETE
  def destroy
    @mail_template.destroy
    respond_to do |format|
      format.html { redirect_to mail_templates_path, notice:  "#{t(:mail_template)} #{t(:was_successfully_deleted)}" }
    end
  end

  private

  # Never trust parameters from the scary internet, only allow the white list through.
  def mail_template_params
    params.require(:mail_template).permit(MailTemplate.accessible_attributes.to_a)
  end

  def new_breadcrumbs
    @breadcrumbs = [[t(:mail_templates), mail_templates_path], ["#{t(:new)} #{t(:mail_template)}"]]
  end

  def show_breadcrumbs
    @breadcrumbs = [[t(:mail_templates), mail_templates_path], [@mail_template.name]]
  end

  def set_default
    @mail_template.attachment = 'sale.invoice_number.pdf'
  end

  def set_variable
    @mail_template.subject = "#{t(:invoice_from)} #{current_organization.name}"
    @mail_template.text = "#{t(:invoice_from)} #{current_organization.name}" + "\n" +
                          '=====================================================' + "\n\n" +
                          "#{t(:see_attached_document)}" + "\n\n" +
                          "#{t(:enter_invoice_number)}"
  end
end
