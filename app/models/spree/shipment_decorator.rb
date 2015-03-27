Spree::Shipment.class_eval do 

  private
    def after_ship
      inventory_units.each do |iu|
        iu.ship!

        iu.line_item.map(&:ad_hoc_option_values).map()

        # stock_items = inventory_units.map(&:line_item).map(&:ad_hoc_option_values).flatten.map(&:products).flatten.map(&:stock_items).flatten
        # stock_items.each do |si|
        #   si.adjust_count_on_hand(-iu.line_item.quantity)
        # end

        iu.line_item.ad_hoc_option_values.each do |ahov|
          ahov.products.each do |p|
            p.stock_items.each do |si|
              si.adjust_count_on_hand(-iu.line_item.quantity)
            end
          end
        end
      end

      send_shipped_email
      touch :shipped_at
      update_order_shipment_state
    end




end