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
    @text = set_text(@sale, mail_template) if mail_template
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
    @text = set_text(@sale, mail_template) if mail_template
    attachments["#{@sale.invoice_number}.pdf"] = File.read(@sale.document.upload.path)
    mail(
        from: @organization.email,
        to: sale.contact_email,
        subject: @subject,
        template_path: 'invoice_mailer'
    )
  end

  def set_text(sale, mail_template)
    return mail_template.text unless mail_template.text.include? '#'

    fields = sale.attributes.merge(contact_attributes(sale))
    set_variables(mail_template.text, fields)
  end

  def set_variables(text, fields)
    ALLOWED_COLUMNS.each do |k, v|
      text.gsub!(k, fields[v])
    end
    return text
  end

  def contact_attributes(sale)
    user_contact = sale.user.contacts.search_by_org(sale.organization).first

    return user_contact.attributes if user_contact

    logger.info '--> invoice_mailer: ' \
                "No contacts found for #{sale.user.email} faling back to user info"
    return {
      'name' => sale.user.name,
      'email' => sale.user.email,
      'telephone' => ' - ' # there is no telephone on the user account
    }
  end
end
