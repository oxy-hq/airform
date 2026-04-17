with base as (

    select *
    from "recharge"."main_recharge_source"."stg_recharge__order_tmp"
),

fields as (

    select
        
    cast(null as integer) as 
    
    id
    
 , 
    cast(null as integer) as 
    
    customer_id
    
 , 
    cast(null as integer) as 
    
    address_id
    
 , 
    cast(null as integer) as 
    
    charge_id
    
 , 
    cast(null as boolean) as 
    
    _fivetran_deleted
    
 , 
    cast(null as TEXT) as 
    
    email
    
 , 
    cast(null as TEXT) as 
    
    transaction_id
    
 , 
    cast(null as TEXT) as 
    
    charge_status
    
 , 
    cast(null as boolean) as 
    
    is_prepaid
    
 , 
    cast(null as TEXT) as 
    
    status
    
 , 
    cast(null as float) as 
    
    total_price
    
 , 
    cast(null as TEXT) as 
    
    type
    
 , 
    cast(null as TEXT) as 
    
    external_order_id_ecommerce
    
 , 
    cast(null as integer) as 
    
    external_order_number_ecommerce
    
 , 
    cast(null as timestamp) as 
    
    created_at
    
 , 
    cast(null as timestamp) as 
    
    updated_at
    
 , 
    cast(null as timestamp) as 
    
    processed_at
    
 , 
    cast(null as timestamp) as 
    
    scheduled_at
    
 , 
    cast(null as timestamp) as 
    
    shipped_date
    
 


        
, 'recharge' || '.'|| 'recharge_integration_tests_03' as source_relation

    from base
),

final as (

    select
        source_relation,
        id as order_id,
        external_order_id_ecommerce,
        external_order_number_ecommerce,
        customer_id,
        email,
        cast(created_at as timestamp) as order_created_at,
        status as order_status,
        cast(updated_at as timestamp) as order_updated_at,
        charge_id,
        transaction_id,
        charge_status,
        is_prepaid,
        cast(total_price as float) as order_total_price,
        type as order_type,
        cast(processed_at as timestamp) as order_processed_at,
        cast(scheduled_at as timestamp) as order_scheduled_at,
        cast(shipped_date as timestamp) as order_shipped_date,
        address_id,
        _fivetran_deleted

        





    from fields
)

select *
from final
