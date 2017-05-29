class InvoiceMailer < ActionMailer::Base
  default from: "no-reply@example.com"

  def invoice_email(sale, mail_template)
    @sale = sale
    @organization = @sale.organization
    @subject = "#{t(:invoice_from)} #{@organization.name}"
    @subject = mail_template.subject if mail_template
    @text = mail_template.text if mail_template
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
    @text = mail_template.text if mail_template
    attachments["#{@sale.invoice_number}.pdf"] = File.read(@sale.document.upload.path)
    mail(
        from: @organization.email,
        to: sale.contact_email,
        subject: @subject,
        template_path: 'invoice_mailer'
    )
  end
end
