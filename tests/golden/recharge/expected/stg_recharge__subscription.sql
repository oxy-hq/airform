with base as (

    select *
    from "recharge"."main_recharge_source"."stg_recharge__subscription_tmp"
),

fields as (

    select
        
    cast(null as integer) as 
    
    id
    
 , 
    cast(null as integer) as 
    
    address_id
    
 , 
    cast(null as integer) as 
    
    customer_id
    
 , 
    cast(null as timestamp) as 
    
    created_at
    
 , 
    cast(null as timestamp) as 
    
    cancelled_at
    
 , 
    cast(null as timestamp) as 
    
    next_charge_scheduled_at
    
 , 
    cast(null as TEXT) as 
    
    price
    
 , 
    cast(null as integer) as 
    
    quantity
    
 , 
    cast(null as TEXT) as 
    
    cancellation_reason
    
 , 
    cast(null as TEXT) as 
    
    status
    
 , 
    cast(null as TEXT) as 
    
    cancellation_reason_comments
    
 , 
    cast(null as TEXT) as 
    
    product_title
    
 , 
    cast(null as TEXT) as 
    
    variant_title
    
 , 
    cast(null as integer) as 
    
    external_product_id_ecommerce
    
 , 
    cast(null as integer) as 
    
    external_variant_id_ecommerce
    
 , 
    cast(null as TEXT) as 
    
    sku
    
 , 
    cast(null as TEXT) as 
    
    order_interval_unit
    
 , 
    cast(null as integer) as 
    
    order_interval_frequency
    
 , 
    cast(null as integer) as 
    
    charge_interval_frequency
    
 , 
    cast(null as integer) as 
    
    order_day_of_week
    
 , 
    cast(null as integer) as 
    
    order_day_of_month
    
 , 
    cast(null as integer) as 
    
    expire_after_specific_number_of_charges
    
 , 
    cast(null as timestamp) as 
    
    updated_at
    
 , 
    cast(null as boolean) as 
    
    _fivetran_deleted
    
 


        
, 'recharge' || '.'|| 'recharge_integration_tests_03' as source_relation

    from base
),

final as (

    select
        source_relation,
        id as subscription_id,
        customer_id,
        address_id,
        cast(created_at as timestamp) as subscription_created_at,
        product_title,
        variant_title,
        sku,
        cast(price as float) as price,
        quantity,
        status as subscription_status,
        next_charge_scheduled_at as subscription_next_charge_scheduled_at,
        charge_interval_frequency,
        expire_after_specific_number_of_charges,
        order_interval_frequency,
        order_interval_unit,
        order_day_of_week,
        order_day_of_month,
        cast(updated_at as timestamp) as subscription_updated_at,
        external_product_id_ecommerce,
        external_variant_id_ecommerce,
        cast(cancelled_at as timestamp) as subscription_cancelled_at,
        cancellation_reason,
        cancellation_reason_comments

        





    from fields
    where not coalesce(_fivetran_deleted, false)
)

select *
from final
