module Statistics
  class SaleStat
    attr_accessor :warehouse, :num_pkg, :sum_amount,
                  :batch_names, :num_sales

    def initialize(args = {})
      @batch_names = []
      @num_pkg = 0
      @sum_amount = 0
      @num_sales = 0
      @warehouse = args[:warehouse]
    end

    def self.list_from_params(organization, newer_than, older_than)
      return [] if newer_than.blank? || older_than.blank?
      sale_stats = []
      newer_than = "#{newer_than}-01"
      older_than = "#{older_than}-01"
      warehouses = organization.warehouses
      warehouses.each do |w|
        sale_stat = from_warehouse_between(w, newer_than, older_than)
        sale_stats << sale_stat if sale_stat.num_sales > 0
      end
      sale_stats
    end

    def self.from_warehouse_between(warehouse, newer_than, older_than)
      sales = sales_from_warehouse(warehouse, newer_than, older_than)
      new_from_sales(warehouse, sales)
    end

    def self.new_from_sales(warehouse, sales)
      sale_stat = new(warehouse: warehouse)
      sales.map do |sale|
        sale_stat.num_sales += 1
        sale.sale_items.map do |item|
          add_item_to(sale_stat, item)
        end
      end
      sale_stat
    end

    def self.add_item_to(sale_stat, item)
      sale_stat.num_pkg += item.quantity
      sale_stat.sum_amount += item.price_sum
      if item.batch && !sale_stat.batch_names.include?(item.batch.name)
        sale_stat.batch_names << item.batch.name
      end
    end

    def self.sales_from_warehouse(warehouse, newer_than, older_than)
      warehouse.sales
               .where('approved_at >= ?', newer_than)
               .where('approved_at <= ?', older_than)
               .includes(:sale_items)
    end

    def self.as_sumarized(sale_stats)
      sale_stat_sum = new
      sale_stat_sum.num_sales = sale_stats.map(&:num_sales).sum
      sale_stat_sum.batch_names = sale_stats.map(&:batch_names)
      sale_stat_sum.num_pkg = sale_stats.map(&:num_pkg).sum
      sale_stat_sum.sum_amount = sale_stats.map(&:sum_amount).sum
      sale_stat_sum
    end

    def self.logger
      Rails.logger
    end

    def logger
      self.class.logger
    end
  end
end
