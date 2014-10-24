class DocumentsController < ApplicationController
  load_and_authorize_resource :document, through: :current_organization
  before_filter :find_and_authorize_parent

  before_filter :show_breadcrumbs, only: [:show, :update]
  before_filter :new_breadcrumbs, only: [:new, :create]

  def index
    @breadcrumbs = [['Documents']]
    @documents = Documents.where('parent_id= ?', 0)
  end

  def new
    if @parent.nil?
      @document = Document.new
      @document_form_url = documents_path(parent_type: 'nil', parent_id: 0)
    else
      @document = @parent.documents.build
      @document_form_url = documents_path(parent_type: @document.parent_type, parent_id: @document.parent_id)
    end
  end

  def show
    @document_form_url = document_path(@document, parent_type: @document.parent_type, parent_id: @document.parent_id)
  end

  def create
    if @parent.nil?
      @document = Document.create document_params
      @document.parent_type = 'nil'
      @document.parent_id = 0
      redirect_path = documents_path
    else
      @document = @parent.documents.build document_params
      redirect_path = edit_polymorphic_path(@parent)
    end
    @document.user = current_user
    @document.organization = current_organization
    if @document.save
      redirect_to redirect_path, notice: "#{t(:document_added)}"
    else
      flash.now[:danger] = "#{t(:failed_to_add)} #{t(:document)}"
      render :new
    end
  end

  def update
    if @parent.nil?
      redirect_path = documents_path
    else
      redirect_path = edit_polymorphic_path(@parent)
    end
    if @document.update(document_params)
      redirect_to redirect_path, notice: "#{t(:document)} #{t(:was_successfully_updated)}"
    else
      flash.now[:danger] = "#{t(:failed_to_update)} #{t(:document)}"
      render :show
    end
  end

  def destroy
    if @parent.nil?
      redirect_path = documents_path
    else
      redirect_path = edit_polymorphic_path(@parent)
    end
    @document.destroy
    redirect_to redirect_path, notice: "#{t(:document)} #{t(:was_destroyed)}"
  end

  private

  def find_and_authorize_parent
    # if comment exists, but no parent_type, add from comment.
    if !params.key?(:parent_type) && !@document.nil?
      params[:parent_type] = @document.parent_type
      params[:parent_id] = @document.parent_id
    end

    unless params.key?(:parent_type)
      params[:parent_type] = 'nil'
      params[:parent_id] = 0
    end

    unless Document::VALID_PARENT_TYPES.include? params[:parent_type]
      logger.info "SECURITY: invalid parent_type(#{params[:parent_type]}) sent to #{request.original_url} "
      redirect_to '/'
      return false
    end

    if params[:parent_type] != 'nil'
      parent_class = params[:parent_type].constantize
      @parent = parent_class.find(params[:parent_id])
      authorize! :manage, @parent
    end
  end

  def document_params
    params.require(:document).permit(Document.accessible_attributes.to_a)
  end

  def show_breadcrumbs
    if !@parent.nil?
      @breadcrumbs = [["#{@document.parent_type.pluralize}", send("#{@parent.class.name.downcase}s_path")],
                      [@document.parent_name, @document.parent], ["#{t(:documents)}(#{@document.name})"]]
    else
      @breadcrumbs = [["#{@document.class.name.pluralize}", send("#{@document.class.name.downcase}s_path")],
                      ["#{t(:documents)}(#{@document.name})"]]
    end
  end

  def new_breadcrumbs
    if !@parent.nil?
      @breadcrumbs = [["#{@parent.class.name.pluralize}", send("#{@parent.class.name.downcase}s_path")],
                      [@parent.parent_name, @parent], ["#{t(:new)} #{t(:document)}"]]
    else
      @breadcrumbs = [["#{@document.class.name.pluralize}", send("#{@document.class.name.downcase}s_path")],
                      ["#{t(:new)} #{t(:document)}"]]
    end
  end
end
