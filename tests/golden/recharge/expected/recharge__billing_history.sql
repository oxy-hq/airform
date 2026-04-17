with orders as (
    select *
    from "recharge"."main_recharge_source"."stg_recharge__order"

), order_line_items as (
    select
        source_relation,
        order_id,
        sum(quantity) as order_item_quantity,
        round(cast(sum(total_price) as numeric(28,6)), 2) as order_line_item_total
    from "recharge"."main_recharge_source"."stg_recharge__order_line_item"
    group by 1, 2


), charges as ( --each charge can have multiple orders associated with it
    select *
    from "recharge"."main_recharge_source"."stg_recharge__charge"

), charge_shipping_lines as (
    select
        source_relation,
        charge_id,
        round(cast(sum(price) as numeric(28,6)), 2) as total_shipping
    from "recharge"."main_recharge_source"."stg_recharge__charge_shipping_line"
    group by 1, 2

), charges_enriched as (
    select
        charges.*,
        charge_shipping_lines.total_shipping
    from charges
    left join charge_shipping_lines
        on charge_shipping_lines.charge_id = charges.charge_id
        and charge_shipping_lines.source_relation = charges.source_relation

), joined as (
    select
        orders.*,
        -- recognized_total (calculated total based on prepaid subscriptions)
        charges_enriched.charge_created_at,
        charges_enriched.payment_processor,
        charges_enriched.tags,
        charges_enriched.orders_count,
        charges_enriched.charge_type,
        
        
            -- when several prepaid orders are generated from a single charge, we only want to show total aggregates from the charge on the first instance.
            case when cast(orders.is_prepaid as integer) = 1 then 0
                else coalesce(charges_enriched.total_price, 0)
                end as charge_total_price,
            -- this divides a charge over all the related orders.
            coalesce(round(cast(
    ( charges_enriched.total_price ) / nullif( ( charges_enriched.orders_count ), 0)
 as numeric(28,6)), 2), 0)
                as calculated_order_total_price,
        
            -- when several prepaid orders are generated from a single charge, we only want to show total aggregates from the charge on the first instance.
            case when cast(orders.is_prepaid as integer) = 1 then 0
                else coalesce(charges_enriched.subtotal_price, 0)
                end as charge_subtotal_price,
            -- this divides a charge over all the related orders.
            coalesce(round(cast(
    ( charges_enriched.subtotal_price ) / nullif( ( charges_enriched.orders_count ), 0)
 as numeric(28,6)), 2), 0)
                as calculated_order_subtotal_price,
        
            -- when several prepaid orders are generated from a single charge, we only want to show total aggregates from the charge on the first instance.
            case when cast(orders.is_prepaid as integer) = 1 then 0
                else coalesce(charges_enriched.tax_lines, 0)
                end as charge_tax_lines,
            -- this divides a charge over all the related orders.
            coalesce(round(cast(
    ( charges_enriched.tax_lines ) / nullif( ( charges_enriched.orders_count ), 0)
 as numeric(28,6)), 2), 0)
                as calculated_order_tax_lines,
        
            -- when several prepaid orders are generated from a single charge, we only want to show total aggregates from the charge on the first instance.
            case when cast(orders.is_prepaid as integer) = 1 then 0
                else coalesce(charges_enriched.total_discounts, 0)
                end as charge_total_discounts,
            -- this divides a charge over all the related orders.
            coalesce(round(cast(
    ( charges_enriched.total_discounts ) / nullif( ( charges_enriched.orders_count ), 0)
 as numeric(28,6)), 2), 0)
                as calculated_order_total_discounts,
        
            -- when several prepaid orders are generated from a single charge, we only want to show total aggregates from the charge on the first instance.
            case when cast(orders.is_prepaid as integer) = 1 then 0
                else coalesce(charges_enriched.total_refunds, 0)
                end as charge_total_refunds,
            -- this divides a charge over all the related orders.
            coalesce(round(cast(
    ( charges_enriched.total_refunds ) / nullif( ( charges_enriched.orders_count ), 0)
 as numeric(28,6)), 2), 0)
                as calculated_order_total_refunds,
        
            -- when several prepaid orders are generated from a single charge, we only want to show total aggregates from the charge on the first instance.
            case when cast(orders.is_prepaid as integer) = 1 then 0
                else coalesce(charges_enriched.total_tax, 0)
                end as charge_total_tax,
            -- this divides a charge over all the related orders.
            coalesce(round(cast(
    ( charges_enriched.total_tax ) / nullif( ( charges_enriched.orders_count ), 0)
 as numeric(28,6)), 2), 0)
                as calculated_order_total_tax,
        
            -- when several prepaid orders are generated from a single charge, we only want to show total aggregates from the charge on the first instance.
            case when cast(orders.is_prepaid as integer) = 1 then 0
                else coalesce(charges_enriched.total_weight_grams, 0)
                end as charge_total_weight_grams,
            -- this divides a charge over all the related orders.
            coalesce(round(cast(
    ( charges_enriched.total_weight_grams ) / nullif( ( charges_enriched.orders_count ), 0)
 as numeric(28,6)), 2), 0)
                as calculated_order_total_weight_grams,
        
            -- when several prepaid orders are generated from a single charge, we only want to show total aggregates from the charge on the first instance.
            case when cast(orders.is_prepaid as integer) = 1 then 0
                else coalesce(charges_enriched.total_shipping, 0)
                end as charge_total_shipping,
            -- this divides a charge over all the related orders.
            coalesce(round(cast(
    ( charges_enriched.total_shipping ) / nullif( ( charges_enriched.orders_count ), 0)
 as numeric(28,6)), 2), 0)
                as calculated_order_total_shipping,
        
        coalesce(order_line_items.order_item_quantity, 0) as order_item_quantity,
        coalesce(order_line_items.order_line_item_total, 0) as order_line_item_total
    from orders
    left join order_line_items
        on order_line_items.order_id = orders.order_id
        and order_line_items.source_relation = orders.source_relation
    left join charges_enriched -- still want to capture charges that don't have an order yet
        on charges_enriched.charge_id = orders.charge_id
        and charges_enriched.source_relation = orders.source_relation

), joined_enriched as (
    select
        joined.*,
        -- total_price includes taxes and discounts, so only need to subtract total_refunds to get net.
        charge_total_price - charge_total_refunds as total_net_charge_value,
        calculated_order_total_price - calculated_order_total_refunds as total_calculated_net_order_value
    from joined
)

select *
from joined_enriched
