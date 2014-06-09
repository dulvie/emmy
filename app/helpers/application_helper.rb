module ApplicationHelper

  # @todo make currency a setting.
  # we currently only support one currency, with the format of 5600 = 56.00 SEK
  def as_sek(integer_number)
    number_to_currency(integer_number / 100.0, precision: 2, format: "%n %u", unit: "SEK")
  end

  # Prints a delete link button
  # depends that the object responds to a .can_delete? method
  def delete_button_for(obj, other_path = nil)
    p = other_path || obj
    return unless obj.can_delete?
    link_to delete_icon, p, method: :delete, data: { confirm: 'Are you Sure?' }
  end

  # @todo Refactor this into an module or something.
  # A couple of short hand methods to make the html a bit nicer.
  # To short to be in a partial, but doesn't belong in a helper...
  def settings_icon
    "<i class=\"glyphicon glyphicon-cog settings-icon\"> </i>".html_safe
  end
  def delete_icon
    "<i class=\"glyphicon glyphicon-trash delete-icon\"> </i>".html_safe
  end
  def plus_icon
    "<i class=\"glyphicon glyphicon-plus-sign plus-icon\"> </i>".html_safe
  end
  def list_icon
    "<i class=\"glyphicon glyphicon-align-justify\"> </i>".html_safe
  end
  def search_icon
    "<i class=\"glyphicon glyphicon-search search_icon\"> </i>".html_safe
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

  def form_submit(sform, text = nil)
    content_tag(:div, class: 'form-group') do
      if text
        sform.button :submit, class: "btn btn-primary", value: text
      else
        sform.button :submit, class: "btn btn-primary"
      end
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
