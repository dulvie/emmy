module Services
  class OpeningBalanceCreator
    def initialize(opening_balance)
      @opening_balance = opening_balance
      @oranization = @opening_balance.organization
      @accounting_period = @opening_balance.accounting_period
    end

    def add_from_ub
      from_period = @accounting_period.previous_accounting_period
      OpeningBalanceItem.transaction do
        from_period.closing_balance.closing_balance_items.each do |item|
          add_opening_balance_item(item.account_id, item.description, item.debit, item.credit)
        end
      end
    end

    def add_opening_balance_item(account, description, debit, credit)
      opening_balance_item = @opening_balance.opening_balance_items.build
      opening_balance_item.organization = @organization
      opening_balance_item.accounting_period = @accounting_period
      opening_balance_item.account_id = account
      opening_balance_item.description = description
      opening_balance_item.debit = debit
      opening_balance_item.credit = credit
      opening_balance_item.save
    end
  end
end
