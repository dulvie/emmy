class InvoiceMailer < ActionMailer::Base
  default from: "no-reply@example.com"

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
    if !mail_template.text.include? "<%"
      return mail_template.text
    elsif sale.user.contacts.present?
      contact = organization.contacts.find(sale.user.contacts)
      return ERB.new(mail_template.text).result(contact.get_binding)
    end
    nil
  end
end