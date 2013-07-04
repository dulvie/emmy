module ApplicationHelper

  # @todo Refactor this into an module or something.
  # A couple of short hand methods to make the html a bit nicer.
  # To short to be in a partial, but doesn't belong in a helper...
  def settings_icon
    "<i class=\"icon-cog settings-icon\"></i>".html_safe
  end
  def delete_icon
    "<i class=\"icon-trash delete-icon\"></i>".html_safe
  end
  def list_icon
    "<i class=\"icon-align-justify\"></i>".html_safe
  end

  # This is hairy, please simplify/shorten
  # Sets class="active" on a navigation <li><a href=".. block.
  def nav_link link_text, link_path
    current_section = get_first_segment request.path
    target_section = get_first_segment link_path
    if target_section.eql? current_section
      content_tag(:li, :class => "active") do
        link_to link_text, link_path
      end
    else
      content_tag(:li) { link_to link_text, link_path }
    end
  end


  private

  # get the first /<section> from a path
  def get_first_segment(link_path)
    s = link_path[1..link_path.size].
        split("/").
        first.
        gsub("/", "")
    # special treatment for dashboard
    s = "dashboard" if s.empty?
    s.to_s
  end

end
