class InvoiceMailer < ActionMailer::Base
  default from: "no-reply@example.com"

  def invoice_email(sale)
    logger.info "HEJ HOPP JAG SKICKAR MAILZORS"
    @sale = sale

    # @todo refactor when implmementing multi-org.
    @organization = Organization.first

    attachments["#{@sale.invoice_number}.pdf"] = File.read(@sale.document.upload.path)
    logger.info "setting from headeR: #{@organization.email}"
    mail(
      from: @organization.email,
      to: sale.contact_email,
      subject: "#{t(:invoice_from)} #{@organization.name}"
    )
  end
end
