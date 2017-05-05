class CommentsController < ApplicationController
  load_and_authorize_resource through: :current_organization
  before_filter :find_and_authorize_parent

  before_filter :show_breadcrumbs, only: [:show, :update]
  before_filter :new_breadcrumbs, only: [:new, :create]

  def index
    @breadcrumbs = [['Comments']]
    @comments = @comments.where('parent_id= ?', 0)
  end

  def new
    if @parent.nil?
      @comment = Comment.new
      @comment_form_url = comments_path(parent_type: 'nil', parent_id: 0)
    else
      @comment = @parent.comments.build
      @comment_form_url = comments_path(parent_type: @comment.parent_type, parent_id: @comment.parent_id)
    end
  end

  def show
    @comment_form_url = comment_path(@comment, parent_type: @comment.parent_type, parent_id: @comment.parent_id)
  end

  def create
    @comment = set_comment
    @comment.user = current_user
    @comment.organization = current_organization

    if @comment.save
      redirect_to redirect_path, notice: "#{t(:comment_added)}"
    else
      flash.now[:danger] = "#{t(:failed_to_add)} #{t(:comment)}"
      init_new
      render :new
    end
  end

  def update
    if @comment.update(comment_params)
      redirect_to redirect_path, notice: "#{t(:comment)} #{t(:was_successfully_updated)}"
    else
      flash.now[:danger] = "#{t(:failed_to_update)} #{t(:comment)}"
      render :show
    end
  end

  def destroy
    @comment.destroy
    redirect_to redirect_path, notice: "#{t(:comment)} #{t(:was_destroyed)}"
  end

  private

  def redirect_path
    if @parent.nil?
      return comments_path
    else
      if [:inventory, :customer, :sale].include?(@parent.class.name.downcase.to_sym)
        return @parent
      else
        return edit_polymorphic_path(@parent)
      end
    end
  end

  def find_and_authorize_parent
    # if comment exists, but no parent_type, add from comment.
    if !params.key?(:parent_type) && !@comment.nil?
      params[:parent_type] = @comment.parent_type
      params[:parent_id] = @comment.parent_id
    end

    unless params.key?(:parent_type)
      params[:parent_type] = 'nil'
      params[:parent_id] = 0
    end

    unless Comment::VALID_PARENT_TYPES.include? params[:parent_type]
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

  def init_new
    if @parent.nil?
      @comment_form_url = comments_path(parent_type: 'nil', parent_id: 0)
    else
      @comment_form_url = comments_path(parent_type: @comment.parent_type, parent_id: @comment.parent_id)
    end
  end

  def set_comment
    if @parent.nil?
      comment = Comment.create comment_params
      comment.parent_type = 'nil'
      comment.parent_id = 0
    else
      comment = @parent.comments.build comment_params
    end
    comment
  end

  def comment_params
    params.require(:comment).permit(Comment.accessible_attributes.to_a)
  end

  def show_breadcrumbs
    if !@parent.nil?
      @breadcrumbs = [["#{@comment.parent_type.pluralize}", send("#{@comment.parent_type.pluralize.downcase}_path")],
                      [@comment.parent_name, @comment.parent], ["#{t(:comments)}(#{@comment.body.to(10) + '...'})"]]
    else
      @breadcrumbs = [["#{@comment.class.name.pluralize}", send("#{@comment.class.name.downcase}s_path")],
                      ["#{t(:comments)}(#{@comment.body.to(10) + '...'})"]]
    end
  end

  def new_breadcrumbs
    if !@parent.nil?
      @breadcrumbs = [["#{@parent.class.name.pluralize}", send("#{@parent.class.name.pluralize.downcase}_path")],
                      [@parent.parent_name, @parent], ["#{t(:new)} #{t(:comment)}"]]
    else
      @breadcrumbs = [["#{@comment.class.name.pluralize}", send("#{@comment.class.name.downcase}s_path")],
                      ["#{t(:new)} #{t(:comment)}"]]
    end
  end
end
