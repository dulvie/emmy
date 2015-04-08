namespace :eko do

  desc 'create verificates from sales'
  task :sales_to_verificates, [:org, :user]  => :environment do |t, args|
    o = Organization.where("name = '#{args.org}'").first
    u = User.where("name = '#{args.user}'").first
    f = DateTime.parse("2015-02-10")
    t = DateTime.parse("2015-02-11")

    #sale = o.sales.where("invoice_number = 5").first
    #verificate_creator = Services::VerificateCreator.new(o, u, sale)
    #verificate_creator.accounts_receivable(true)

    sales = o.sales.where("approved_at > ? and approved_at < ? and state <> 'canceled'", f, t)
    sales.each do |sale|
      puts sale.invoice_number
      verificate_creator = Services::VerificateCreator.new(o, u, sale)
      verificate_creator.accounts_receivable(true)
    end
  end

  desc 'create verificates for sales payments'
  task :sales_payments_to_verificates, [:org, :user]  => :environment do |t, args|
    o = Organization.where("name = '#{args.org}'").first
    u = User.where("name = '#{args.user}'").first
    f = DateTime.parse("2015-02-10")
    t = DateTime.parse("2015-02-12")

    # sale = o.sales.where("invoice_number = 2").first
    # verificate_creator = Services::VerificateCreator.new(o, u, sale)
    # verificate_creator.customer_payments

    sales = o.sales.where("paid_at > ? and paid_at < ? and state <> 'canceled'", f, t)
    sales.each do |sale|
      puts sale.invoice_number
      verificate_creator = Services::VerificateCreator.new(o, u, sale)
      verificate_creator.customer_payments
    end
  end
end