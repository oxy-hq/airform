with base as (

    select * 
    from "amazon_selling_partner"."main_stg_amazon_selling_partner"."stg_amazon_selling_partner__orders_base"
),

fields as (

    select
        
    cast(null as TEXT) as 
    
    amazon_order_id
    
 , 
    cast(null as TEXT) as 
    
    automated_shipping_setting_automated_carrier
    
 , 
    cast(null as TEXT) as 
    
    automated_shipping_setting_automated_ship_method
    
 , 
    cast(null as boolean) as 
    
    automated_shipping_setting_has_automated_shipping_settings
    
 , 
    cast(null as TEXT) as 
    
    buyer_info_buyer_email
    
 , 
    cast(null as TEXT) as 
    
    buyer_info_buyer_name
    
 , 
    cast(null as TEXT) as 
    
    buyer_info_purchase_order_number
    
 , 
    cast(null as TEXT) as 
    
    default_ship_from_location_address_line_1
    
 , 
    cast(null as TEXT) as 
    
    default_ship_from_location_address_line_2
    
 , 
    cast(null as integer) as 
    
    default_ship_from_location_address_line_3
    
 , 
    cast(null as integer) as 
    
    default_ship_from_location_address_type
    
 , 
    cast(null as TEXT) as 
    
    default_ship_from_location_city
    
 , 
    cast(null as TEXT) as 
    
    default_ship_from_location_country_code
    
 , 
    cast(null as TEXT) as 
    
    default_ship_from_location_county
    
 , 
    cast(null as integer) as 
    
    default_ship_from_location_district
    
 , 
    cast(null as integer) as 
    
    default_ship_from_location_municipality
    
 , 
    cast(null as TEXT) as 
    
    default_ship_from_location_name
    
 , 
    cast(null as integer) as 
    
    default_ship_from_location_phone
    
 , 
    cast(null as integer) as 
    
    default_ship_from_location_postal_code
    
 , 
    cast(null as integer) as 
    
    default_ship_from_location_state_or_region
    
 , 
    cast(null as TEXT) as 
    
    earliest_delivery_date
    
 , 
    cast(null as TEXT) as 
    
    earliest_ship_date
    
 , 
    cast(null as TEXT) as 
    
    easy_ship_shipment_status
    
 , 
    cast(null as TEXT) as 
    
    electronic_invoice_status
    
 , 
    cast(null as TEXT) as 
    
    fulfillment_channel
    
 , 
    cast(null as TEXT) as 
    
    fulfillment_supply_source_id
    
 , 
    cast(null as boolean) as 
    
    has_regulated_items
    
 , 
    cast(null as boolean) as 
    
    is_access_point_order
    
 , 
    cast(null as boolean) as 
    
    is_business_order
    
 , 
    cast(null as boolean) as 
    
    is_estimated_ship_date_set
    
 , 
    cast(null as boolean) as 
    
    is_global_express_enabled
    
 , 
    cast(null as boolean) as 
    
    is_iba
    
 , 
    cast(null as boolean) as 
    
    is_ispu
    
 , 
    cast(null as boolean) as 
    
    is_premium_order
    
 , 
    cast(null as boolean) as 
    
    is_prime
    
 , 
    cast(null as boolean) as 
    
    is_replacement_order
    
 , 
    cast(null as boolean) as 
    
    is_sold_by_ab
    
 , 
    cast(null as timestamp) as 
    
    last_update_date
    
 , 
    cast(null as timestamp) as 
    
    latest_delivery_date
    
 , 
    cast(null as timestamp) as 
    
    latest_ship_date
    
 , 
    cast(null as TEXT) as 
    
    marketplace_id
    
 , 
    cast(null as integer) as 
    
    number_of_items_shipped
    
 , 
    cast(null as integer) as 
    
    number_of_items_unshipped
    
 , 
    cast(null as TEXT) as 
    
    order_channel
    
 , 
    cast(null as TEXT) as 
    
    order_status
    
 , 
    cast(null as TEXT) as 
    
    order_total_amount
    
 , 
    cast(null as TEXT) as 
    
    order_total_currency_code
    
 , 
    cast(null as TEXT) as 
    
    order_type
    
 , 
    cast(null as TEXT) as 
    
    payment_method
    
 , 
    cast(null as timestamp) as 
    
    promise_response_due_date
    
 , 
    cast(null as timestamp) as 
    
    purchase_date
    
 , 
    cast(null as TEXT) as 
    
    replaced_order_id
    
 , 
    cast(null as TEXT) as 
    
    sales_channel
    
 , 
    cast(null as TEXT) as 
    
    seller_order_id
    
 , 
    cast(null as TEXT) as 
    
    ship_service_level
    
 , 
    cast(null as TEXT) as 
    
    shipment_service_level_category
    
 , 
    cast(null as TEXT) as 
    
    shipping_address_address_line_1
    
 , 
    cast(null as integer) as 
    
    shipping_address_address_line_2
    
 , 
    cast(null as integer) as 
    
    shipping_address_address_line_3
    
 , 
    cast(null as integer) as 
    
    shipping_address_address_type
    
 , 
    cast(null as TEXT) as 
    
    shipping_address_city
    
 , 
    cast(null as integer) as 
    
    shipping_address_country_code
    
 , 
    cast(null as integer) as 
    
    shipping_address_county
    
 , 
    cast(null as integer) as 
    
    shipping_address_district
    
 , 
    cast(null as integer) as 
    
    shipping_address_municipality
    
 , 
    cast(null as integer) as 
    
    shipping_address_name
    
 , 
    cast(null as integer) as 
    
    shipping_address_phone
    
 , 
    cast(null as integer) as 
    
    shipping_address_postal_code
    
 , 
    cast(null as TEXT) as 
    
    shipping_address_state_or_region
    
 


        
        
, 'amazon_selling_partner' || '.'|| 'asp_integration_tests' as source_relation

        
    from base
),

final as (
    
    select 
        source_relation, 
        amazon_order_id,
        marketplace_id,
        replaced_order_id,
        seller_order_id,
        buyer_info_purchase_order_number,
        purchase_date,
        sales_channel,
        order_channel,
        order_type,
        order_status,
        payment_method,
        cast(REPLACE(order_total_amount, ',', '') as numeric(28,6)) as order_total_amount,
        order_total_currency_code,
        promise_response_due_date,
        last_update_date,
        latest_delivery_date,
        latest_ship_date,
        number_of_items_shipped,
        number_of_items_unshipped,
        earliest_delivery_date,
        earliest_ship_date,
        easy_ship_shipment_status,
        electronic_invoice_status,
        fulfillment_channel,
        fulfillment_supply_source_id,
        has_regulated_items,
        is_access_point_order,
        is_business_order,
        is_estimated_ship_date_set,
        is_global_express_enabled,
        is_iba,
        is_ispu,
        is_premium_order,
        is_prime,
        is_replacement_order,
        is_sold_by_ab,
        ship_service_level,
        shipment_service_level_category,
        automated_shipping_setting_automated_carrier,
        automated_shipping_setting_automated_ship_method,
        automated_shipping_setting_has_automated_shipping_settings,
        default_ship_from_location_address_line_1,
        default_ship_from_location_address_line_2,
        default_ship_from_location_address_line_3,
        default_ship_from_location_address_type,
        default_ship_from_location_city,
        default_ship_from_location_country_code,
        default_ship_from_location_county,
        default_ship_from_location_district,
        default_ship_from_location_municipality,
        default_ship_from_location_name,
        default_ship_from_location_phone,
        default_ship_from_location_postal_code,
        default_ship_from_location_state_or_region,
        
        
        shipping_address_address_type,
        shipping_address_city,
        shipping_address_country_code,
        shipping_address_county,
        shipping_address_district,
        shipping_address_municipality,
        shipping_address_postal_code,
        shipping_address_state_or_region

    from fields
)

select *
from final
