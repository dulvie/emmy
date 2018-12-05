# encoding: utf-8
module ApplicationHelper

  # @todo make currency a setting.
  # we currently only support one currency, with the format of 5600 = 56.00 SEK
  def as_sek(integer_number, unit = 'SEK')
    number_to_currency(integer_number / 100.0, precision: 2, format: "%n %u", unit: unit)
  end

  # Prints a delete link button
  # depends that the object responds to a .can_delete? method
  def delete_button_for(obj, other_path = nil)
    p = other_path || obj
    return unless obj.can_delete?
    link_to delete_icon, p, method: :delete, data: { confirm: 'Are you Sure?' }
  end

  def agreement_button_for(obj, other_path = nil)
    p = other_path || obj
    link_to briefcase_icon, p
  end

  def report_button_for(obj, other_path = nil)
    p = other_path || obj
    link_to tasks_icon, p
  end

  def active_button_for(obj, other_path = nil)
    p = other_path || obj
    return link_to active_icon, p, method: 'post' if obj.active == true
    return link_to inactive_icon, p, method: 'post' if obj.active == false
    link_to task_icon, p
  end

  def delete_button_for(obj, other_path = nil)
    return unless obj.can_delete?
    path = other_path || url_for(obj)
    link_to t(:clear), obj, :ng_click =>"open_delete($event, 'sm','deleteContent', '#{path}')", class: 'btn btn-warning'
  end

  def delete_modal_for(obj, other_path = nil)
    return unless obj.can_delete?
    path = other_path || url_for(obj)
    link_to delete_icon(obj), '#', :ng_click =>"open_delete($event, 'sm','deleteContent', '#{path}')"
  end

  def delete_modal(obj, other_path = nil, modalId)
    return unless obj.can_delete?
    path = other_path || url_for(obj)
    link_to delete_icon(obj), '#', :class=>'dlt', :'data-toggle' => 'modal', :'data-target'=>modalId, :'data-path'=>path
  end

  def info_modal(modal)
    link_to info_icon, '#', :'data-toggle' => 'modal', :'data-target'=>modal
  end

  def info_modal_for(obj)
    link_to info_icon, '#', :ng_click => "show_info($event, '#{obj}')"
  end

  def import_button_for(obj, other_path = nil)
    p = other_path || obj
    link_to import_icon, p
  end

  # @todo Refactor this into an module or something.
  # A couple of short hand methods to make the html a bit nicer.
  # To short to be in a partial, but doesn't belong in a helper...
  def settings_icon
    "<i class=\"glyphicon glyphicon-cog settings-icon\"> </i>".html_safe
  end

  def delete_icon(obj = nil)
    if obj
      # Downcase and remove 'decorator' from the class name.
      obj_origin_class_name = obj.class.name.downcase.gsub('decorator','')
      extra_css_class = "#{obj_origin_class_name}-#{obj.id}"
    end
    glyphicon('trash', "delete-icon #{extra_css_class}")
  end

  def download_icon
    glyphicon('download-alt', 'download-alt-icon')
  end
  def active_icon
    glyphicon('ok-circle', 'ok-circle-icon')
  end
  def inactive_icon
    glyphicon('ban-circle', 'ban_circle-icon')
  end
  def link_icon
    glyphicon('link', 'link-icon')
  end
  def briefcase_icon
    glyphicon('briefcase', 'briefcase-icon')
  end
  def refresh_icon
    glyphicon('refresh', 'refresh-icon')
  end
  def tasks_icon
    glyphicon('tasks', 'tasks-icon')
  end
  def import_icon
    glyphicon('import', 'import-icon')
  end
  def nav_icon
    glyphicon('align-justify')
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
  def status_icon
    "<i class=\"glyphicon glyphicon-flag status_icon\"> </i>".html_safe
  end
  def ok_icon
    "<i class=\"glyphicon glyphicon-ok ok_icon\"> </i>".html_safe
  end
  def doc_icon
    "<i class=\"glyphicon glyphicon-file file_icon\"> </i>".html_safe
  end
  def edit_icon
    "<i class=\"glyphicon glyphicon-edit edit_icon\"> </i>".html_safe
  end
  def info_icon
    "<i class=\"glyphicon glyphicon-info-sign info_icon\"> </i>".html_safe
  end
  def right_icon
    "<i class=\"glyphicon glyphicon-chevron-right right_icon\"> </i>".html_safe
  end
  def envelope_icon
    "<i class=\"glyphicon glyphicon-envelope envelope_icon\"> </i>".html_safe
  end

  def user_icon
    glyphicon('user', 'refresh-user')
  end

  def glyphicon(icon_name, extra_css_classes = '')
    class_string = "glyphicon glyphicon-#{icon_name} #{extra_css_classes}"
    content_tag(:i, ' ', class: class_string)
  end

  def nav_link link_text, link_path
    if current_page? link_path
      content_tag(:li, class: 'active') { link_to link_text, link_path }
    else
      content_tag(:li) { link_to link_text, link_path }
    end
  end

  def dropdown_link(link_text)
    content_tag(:a, 'class' => 'toggler',
                    'data-toggle' => 'dropdown',
                    'href' => '#') do
      link_text
    end
  end

  def dropdown_class(headline)
    return 'dropdown active' if dropdown_auto_open(headline)
    'dropdown'
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

  def labelify(str, label_state)
    content_tag :span, class: "label label-#{label_state}" do
      str
    end
  end

  def months_list
    a = []
    (2011..Time.now.year).each do |year|
      (1..12).each do |month|
        a << [sprintf('%d %02d', year, month), sprintf('%d-%02d', year, month)]
      end
    end
    a.reverse
  end


  def general_controllers
    %w(organizations users contacts comments help)
  end

  def logistics_controllers
    %w(warehouses items batches units vats inventories stock_values)
  end

  def purchase_controllers
    %w(suppliers purchases imports productions)
  end

  def transfers_controllers
    %w(transfers manual_transactions)
  end

  def sales_controllers
    %w(customers sales)
  end

  def economics_controllers
    %w(accounting_plans tax_codes ink_codes ne_codes default_codes tax_tables employees result_units templates)
  end

  def accounting_controllers
    %w(accounting_periods verificates vat_periods wage_periods tax_returns)
  end

  def interchanges_controllers
    %w(sie_imports sie_exports import_bank_files export_bank_files)
  end

  def reports_controllers
    %w(accounts_receivables accounts_payables reports)
  end

  def dropdown_auto_open(headline)
    if general_controllers.include? controller_name
      return headline == 'general'
    elsif logistics_controllers.include? controller_name
      return headline == 'logistics'
    elsif purchase_controllers.include? controller_name
      return headline == 'purchase'
    elsif transfers_controllers.include? controller_name
      return headline == 'transfers'
    elsif sales_controllers.include? controller_name
      return headline == 'sales'
    elsif economics_controllers.include? controller_name
      return headline == 'economics'
    elsif accounting_controllers.include? controller_name
      return headline == 'accounting'
    elsif interchanges_controllers.include? controller_name
      return headline == 'interchanges'
    elsif reports_controllers.include? controller_name
      return headline == 'reports'
    else
      false
    end
  end

  def wizard_url(url_parts)
    url_for(controller: url_parts[0], action: url_parts[1])
  end

end
