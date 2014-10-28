class InvoiceMailer < ActionMailer::Base
  default from: "no-reply@example.com"

  def invoice_email(sale)
    @sale = sale
    @organization = @sale.organization
    attachments["#{@sale.invoice_number}.pdf"] = File.read(@sale.document.upload.path)
    mail(
      from: @organization.email,
      to: sale.contact_email,
      subject: "#{t(:invoice_from)} #{@organization.name}"
    )
  end
end
