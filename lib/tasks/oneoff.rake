namespace :oneoff do
  desc 'recalculate items for all sales'
  task :recalculate_sale_items => :environment do
    result = {saved: 0, runned_on: 0}
    Sale.all.each do |sale|
      sale.sale_items.each do |item|
        result[:runned_on] += 1
        item.valid?
        if item.changed?
          result[:saved] += 1
          puts "saving #{item.desc} for #{sale.id}"
          item.save
        end
      end
    end
    puts "result: #{result.inspect}"
  end
end
