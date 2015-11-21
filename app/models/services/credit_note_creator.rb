module Services
  class CreditNoteCreator
    def initialize(organization, user, reference)
      @user = user
      @organization = organization
      @reference = reference
    end

    def save
      ref_sale_items = @organization.sale_items.where('sale_id = ?', @reference.id)
      return 0 if ref_sale_items.nil?

      @sale = init_sale
      return 0 unless @sale.save

      ref_sale_items.each do |item|
        Rails.logger.info "Raden #{item.inspect}"
        @sale_item = @sale.sale_items.build
        if item[:batch_id].to_i > 0
          @sale_item.item_id = item[:item_id]
          @sale_item.batch_id = item[:batch_id]
          @sale_item.price = item[:price]
          @sale_item.quantity = item[:quantity]
          @sale_item.vat = item[:vat]
        elsif item[:item_id].to_i > 0
          @sale_item.item_id = item[:item_id]
          @sale_item.price = item[:price]
          @sale_item.quantity = item[:quantity]
          @sale_item.vat = item[:vat]
        else
          @sale_item.name = item[:name]
          @sale_item.price = item[:price]
          @sale_item.quantity = item[:quantity]
          @sale_item.vat = item[:vat]
        end
        @sale_item.save
      end
      @reference.credit_reference = @sale.id
      @reference.save
      @sale.id
    end

    def init_sale
      @sale = Sale.new
      @sale.credit = true
      @sale.credit_reference = @reference.id
      @sale.warehouse_id = @reference.warehouse_id
      @sale.customer_id = @reference.customer_id
      @sale.user_id = @user.id
      @sale.organization = @organization
      @sale.contact_name = @reference.contact_name
      @sale.contact_email = @reference.contact_email
      @sale.contact_telephone = @reference.contact_telephone
      @sale.payment_term = @reference.payment_term
      Rails.logger.info "Testar #{@sale.inspect}"
      @sale
    end
  end
end
