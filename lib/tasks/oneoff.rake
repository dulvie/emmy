namespace :oneoff do
  desc 'recalculate items for all sales'
  task :recalculate_sale_items => :environment do
    result = {saved: 0, runned_on: 0, new_invoice: 0}
    Sale.all.each do |sale|
      changed = false
      sale.sale_items.each do |item|
        result[:runned_on] += 1
        item.valid?
        if item.changed?
          changed = true
          result[:saved] += 1
          puts "saving #{item.desc} for #{sale.id}"
          item.save
        end
      end

      # If changed, generate a new invoice also.
      if changed
        sale.document.destroy
        sale.generate_invoice
        result[:new_invoice] += 1
      end
    end
    puts "result: #{result.inspect}"
  end
end
