module Spree
  OrderContents.class_eval do
    # Get current line item for variant if exists
    # Add variant qty to line_item
    def add(variant, quantity = 1, options = {}, ad_hoc_option_value_ids = [], product_customizations = [])
      timestamp = Time.now
      line_item = order.find_line_item_by_variant(variant)
      add_to_line_item(line_item, variant, quantity, currency, shipment, ad_hoc_option_value_ids, product_customizations)
      options[:line_item_created] = true if timestamp <= line_item.created_at
      after_add_or_remove(line_item, options)
    end

    private
      def add_to_line_item(line_item, variant, quantity, currency=nil, shipment=nil, ad_hoc_option_value_ids = [], product_customizations = [])
        if line_item
          line_item.target_shipment = shipment
          line_item.quantity += quantity.to_i
          line_item.currency = currency unless currency.nil?
        else
          line_item = order.line_items.new(quantity: quantity, variant: variant)
          line_item.target_shipment = shipment
          line_item.product_customizations = product_customizations
          product_customizations.each {|pc| pc.line_item = line_item}
          product_customizations.map(&:save)
          povs=[]
            ad_hoc_option_value_ids.each do |cid|
              povs << AdHocOptionValue.find(cid)
            end
            line_item.ad_hoc_option_values = povs
            puts line_item.inspect
            puts povs.inspect

            offset_price   = povs.map(&:price_modifier).compact.sum + product_customizations.map {|pc| pc.price(variant)}.sum

            puts offset_price.inspect
          if currency
            line_item.currency = currency unless currency.nil?
            line_item.price    = variant.price_in(currency).amount + offset_price
          else
            line_item.price    = variant.price + offset_price
          end
        end

        line_item.save
        order.reload
        line_item
      end
  
      def grab_line_item_by_variant(variant, raise_error = false, options = {}, ad_hoc_option_value_ids, product_customizations)
        line_item = order.find_line_item_by_variant(variant, options, ad_hoc_option_value_ids, product_customizations)

        if !line_item.present? && raise_error
          raise ActiveRecord::RecordNotFound, "Line item not found for variant #{variant.sku}"
        end

        line_item
    end
  end
end
