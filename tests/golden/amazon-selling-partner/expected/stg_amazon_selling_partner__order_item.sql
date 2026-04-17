with base as (

    select * 
    from "amazon_selling_partner"."main_stg_amazon_selling_partner"."stg_amazon_selling_partner__order_item_base"
),

fields as (

    select
        
    cast(null as TEXT) as 
    
    amazon_order_id
    
 , 
    cast(null as TEXT) as 
    
    asin
    
 , 
    cast(null as TEXT) as 
    
    buyer_requested_cancel_buyer_cancel_reason
    
 , 
    cast(null as boolean) as 
    
    buyer_requested_cancel_is_buyer_requested_cancel
    
 , 
    cast(null as TEXT) as 
    
    condition_id
    
 , 
    cast(null as TEXT) as 
    
    condition_note
    
 , 
    cast(null as TEXT) as 
    
    condition_subtype_id
    
 , 
    cast(null as TEXT) as 
    
    deemed_reseller_category
    
 , 
    cast(null as TEXT) as 
    
    ioss_number
    
 , 
    cast(null as boolean) as 
    
    is_gift
    
 , 
    cast(null as boolean) as 
    
    is_transparency
    
 , 
    cast(null as TEXT) as 
    
    item_price_amount
    
 , 
    cast(null as TEXT) as 
    
    item_price_currency_code
    
 , 
    cast(null as TEXT) as 
    
    item_tax_amount
    
 , 
    cast(null as TEXT) as 
    
    item_tax_currency_code
    
 , 
    cast(null as TEXT) as 
    
    order_item_id
    
 , 
    cast(null as integer) as 
    
    product_info_detail_number_of_items
    
 , 
    cast(null as TEXT) as 
    
    promotion_discount_amount
    
 , 
    cast(null as TEXT) as 
    
    promotion_discount_currency_code
    
 , 
    cast(null as TEXT) as 
    
    promotion_discount_tax_amount
    
 , 
    cast(null as TEXT) as 
    
    promotion_discount_tax_currency_code
    
 , 
    cast(null as integer) as 
    
    quantity_ordered
    
 , 
    cast(null as integer) as 
    
    quantity_shipped
    
 , 
    cast(null as date) as 
    
    scheduled_delivery_end_date
    
 , 
    cast(null as date) as 
    
    scheduled_delivery_start_date
    
 , 
    cast(null as TEXT) as 
    
    seller_sku
    
 , 
    cast(null as boolean) as 
    
    serial_number_required
    
 , 
    cast(null as TEXT) as 
    
    shipping_discount_amount
    
 , 
    cast(null as TEXT) as 
    
    shipping_discount_currency_code
    
 , 
    cast(null as TEXT) as 
    
    shipping_discount_tax_amount
    
 , 
    cast(null as TEXT) as 
    
    shipping_discount_tax_currency_code
    
 , 
    cast(null as TEXT) as 
    
    shipping_price_amount
    
 , 
    cast(null as TEXT) as 
    
    shipping_price_currency_code
    
 , 
    cast(null as TEXT) as 
    
    shipping_tax_amount
    
 , 
    cast(null as TEXT) as 
    
    shipping_tax_currency_code
    
 , 
    cast(null as TEXT) as 
    
    store_chain_store_id
    
 , 
    cast(null as TEXT) as 
    
    tax_collection_model
    
 , 
    cast(null as TEXT) as 
    
    tax_collection_responsible_party
    
 , 
    cast(null as TEXT) as 
    
    title
    
 


        
        
, 'amazon_selling_partner' || '.'|| 'asp_integration_tests' as source_relation

        
    from base
),

final as (
    
    select 
        source_relation, 
        amazon_order_id,
        order_item_id,
        cast(asin as TEXT) as asin,
        seller_sku,
        title,
        product_info_detail_number_of_items,
        scheduled_delivery_start_date,
        scheduled_delivery_end_date,
        quantity_ordered,
        quantity_shipped,
        cast(REPLACE(item_price_amount, ',', '') as numeric(28,6)) as item_price_amount,
        item_price_currency_code,
        cast(REPLACE(item_tax_amount, ',', '') as numeric(28,6)) as item_tax_amount,
        item_tax_currency_code,
        cast(REPLACE(shipping_discount_amount, ',', '') as numeric(28,6)) as shipping_discount_amount,
        shipping_discount_currency_code,
        cast(REPLACE(shipping_discount_tax_amount, ',', '') as numeric(28,6)) as shipping_discount_tax_amount,
        shipping_discount_tax_currency_code,
        cast(REPLACE(shipping_price_amount, ',', '') as numeric(28,6)) as shipping_price_amount,
        shipping_price_currency_code,
        cast(REPLACE(shipping_tax_amount, ',', '') as numeric(28,6)) as shipping_tax_amount,
        shipping_tax_currency_code,
        cast(REPLACE(promotion_discount_amount, ',', '') as numeric(28,6)) as promotion_discount_amount,
        promotion_discount_currency_code,
        cast(REPLACE(promotion_discount_tax_amount, ',', '') as numeric(28,6)) as promotion_discount_tax_amount,
        promotion_discount_tax_currency_code,
        condition_id,
        condition_note,
        condition_subtype_id,
        buyer_requested_cancel_buyer_cancel_reason as buyer_requested_cancel_reason,
        buyer_requested_cancel_is_buyer_requested_cancel as is_buyer_requested_cancel,
        deemed_reseller_category,
        ioss_number,
        is_gift,
        is_transparency,
        serial_number_required as is_serial_number_required, -- only populated for Easy Ship orders
        store_chain_store_id,
        tax_collection_model, -- always MarketplaceFacilitator in US
        tax_collection_responsible_party -- always Amazon Web Services in US
        
    from fields
)

select *
from final
