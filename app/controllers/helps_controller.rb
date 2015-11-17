class HelpsController < ApplicationController
  respond_to :html, :json, :pdf
  skip_authorization_check

  def show_help
    @breadcrumbs = [["#{t(:help)}"]]
  end

  def show_chapter_help
    render layout: false
  end

  def show_message
    @breadcrumbs = [["#{t(:help)}"]]
  end
end
