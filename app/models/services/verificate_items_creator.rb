module Services
  class VerificateItemsCreator
    def initialize(organization, user, verificate, verificate_items)
      @user = user
      @organization = organization
      @verificate = verificate
      @verificate_items = verificate_items
    end

    def save
      @verificate_items[:row].each do |item|
        verificate_item = @verificate.verificate_items.build
        verificate_item.organization = @organization
        verificate_item.accounting_period = @verificate.accounting_period
        verificate_item.account_id = item[1][:account_id]
        verificate_item.description = item[1][:description]
        verificate_item.result_unit_id = item[1][:result_unit] if item[1][:result_unit]
        verificate_item.debit = item[1][:debit]
        verificate_item.credit = item[1][:credit]
        verificate_item.save if item[1][:debit] != '0' || item[1][:credit] != '0'
      end
      if @verificate.balanced?
        # @verificate.state_change('mark_final', @verificate_items[:verificate][:posting_date])
        return true
      end
    end
  end
end
