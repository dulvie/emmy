module Services
  class TemplateCreator
    require 'csv'

    def initialize(organization, user, accounting_plan)
      @user = user
      @organization = organization
      @accounting_plan = accounting_plan
      @template = nil
    end

    def read_and_save
      # OBS olika filnam beroende på accounting_plan
      name = 'files/templates/templates_Bas.csv' if @accounting_plan.file_name.include? 'Normal_20'
      name = 'files/templates/templates_K1.csv' if @accounting_plan.file_name.include? 'K1_20'
      name = 'files/templates/templates_Mini.csv' if @accounting_plan.file_name.include? 'Mini_20'

      CSV.foreach(name, { :col_sep => ';' }) do |row|

        #template, name, description, type
        save_template(row[1], row[2], row[3]) if row[0] == '#template'

        #template_item; account; debit; credit
        save_template_item(row[1], row[2], row[3]) if row[0] == '#template_item' && @template
      end
      return true
    end

    def save_template(name, description, type)
      @template = Template.new
      @template.name = name
      @template.description = description
      @template.template_type = type
      @template.accounting_plan= @accounting_plan
      @template.organization = @organization
      @template.save
    end

    def save_template_item(account_number, enable_debit, enable_credit)
      account = @accounting_plan.accounts.where('number = ?', account_number).first
      template_item = @template.template_items.build
      template_item.account = account
      template_item.description = account.description
      template_item.enable_debit = enable_debit
      template_item.enable_credit = enable_credit
      template_item.organization = @organization
      template_item.save
    end
  end
end
