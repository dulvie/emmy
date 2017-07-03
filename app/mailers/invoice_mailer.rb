class InvoiceMailer < ActionMailer::Base
  default from: "no-reply@example.com"
  ALLOWED_COLUMNS = ['#contact_name', '#name', '#telephone', '#email']

  def invoice_email(sale, mail_template)
    @sale = sale
    @organization = @sale.organization
    @subject = "#{t(:invoice_from)} #{@organization.name}"
    @subject = mail_template.subject if mail_template
    @text = set_text(@organization, @sale, mail_template) if mail_template
    attachments["#{@sale.invoice_number}.pdf"] = File.read(@sale.document.upload.path)
    mail(
      from: @organization.email,
      to: sale.contact_email,
      subject: @subject
    )
  end

  def reminder_email(sale, mail_template)
    @sale = sale
    @organization = @sale.organization
    @subject = "#{t(:reminder_from)} #{@organization.name}"
    @subject = mail_template.subject if mail_template
    @text = set_text(@organization, @sale, mail_template) if mail_template
    attachments["#{@sale.invoice_number}.pdf"] = File.read(@sale.document.upload.path)
    mail(
        from: @organization.email,
        to: sale.contact_email,
        subject: @subject,
        template_path: 'invoice_mailer'
    )
  end

  def set_text(organization, sale, mail_template)
    if !mail_template.text.include? "#"
      return mail_template.text
    elsif sale.user.contacts.present?
      sale_fields = sale.attributes
      contact_fields = organization.contacts.find(sale.user.contacts).attributes
      fields = sale_fields.merge(contact_fields)
      return set_variables(mail_template.text, ALLOWED_COLUMNS, fields)
    end
    nil
  end

  def set_variables(text, columns, fields)
    columns.each do |col|
      val = fields[col[1..-1]]
      text.gsub! col, val
    end
    return text
  end
end