Deface::Override.new(
  :virtual_path => "spree/admin/orders/_stock_item",
  :name => "display_selected_ad_hoc_options_for_orders",
  :insert_bottom => '.item-name',
  :partial => "spree/admin/orders/ad_hoc_option_values"
)