with base as (

    select *
    from "recharge"."main_recharge_source"."stg_recharge__one_time_product_tmp"
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
    
    updated_at
    
 , 
    cast(null as timestamp) as 
    
    next_charge_scheduled_at
    
 , 
    cast(null as TEXT) as 
    
    product_title
    
 , 
    cast(null as TEXT) as 
    
    variant_title
    
 , 
    cast(null as integer) as 
    
    price
    
 , 
    cast(null as integer) as 
    
    quantity
    
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
    cast(null as boolean) as 
    
    _fivetran_deleted
    
 


        
, 'recharge' || '.'|| 'recharge_integration_tests_03' as source_relation

    from base
),

final as (

    select
        source_relation,
        id as one_time_product_id,
        address_id,
        customer_id,
        _fivetran_deleted,
        cast(created_at as timestamp) as one_time_created_at,
        cast(updated_at as timestamp) as one_time_updated_at,
        next_charge_scheduled_at as one_time_next_charge_scheduled_at,
        product_title,
        variant_title,
        price,
        quantity,
        external_product_id_ecommerce,
        external_variant_id_ecommerce,
        sku
    from fields
    where not coalesce(_fivetran_deleted, false)
)

select *
from final
