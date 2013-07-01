module ApplicationHelper

  # Sets class="active" on a navigation <li><a href=".. block.
  def nav_link link_text, link_path

    # get the first /<section> from the path
    c = link_path[1..link_path.size].
        split("/").
        first.
        gsub("/", "")

    # special treatment for dashboard
    c = "dashboard" if c.empty?

    if c.eql? params[:controller].to_s
      content_tag(:li, :class => "active") do
        link_to link_text, link_path
      end
    else
      content_tag(:li) { link_to link_text, link_path }
    end
  end

end
