class InvoiceMailer < ActionMailer::Base
  default from: "no-reply@example.com"
  ALLOWED_COLUMNS = {'#recipient_name'   => 'contact_name',
                     '#sender_name'      => 'name',
                     '#sender_telephone' => 'telephone',
                     '#sender_email'     => 'email'}

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
      return set_variables(mail_template.text, fields)
    end
    nil
  end

  def set_variables(text, fields)
    ALLOWED_COLUMNS.each do | k, v |
      text.gsub! k, fields[v]
    end
    return text
  end
end