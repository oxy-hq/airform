with base as (

    select *
    from "recharge"."main_recharge_source"."stg_recharge__discount_tmp"
),

fields as (

    select
        
    cast(null as integer) as 
    
    id
    
 , 
    cast(null as timestamp) as 
    
    created_at
    
 , 
    cast(null as timestamp) as 
    
    updated_at
    
 , 
    cast(null as timestamp) as 
    
    starts_at
    
 , 
    cast(null as timestamp) as 
    
    ends_at
    
 , 
    cast(null as TEXT) as 
    
    code
    
 , 
    cast(null as float) as 
    
    value
    
 , 
    cast(null as TEXT) as 
    
    status
    
 , 
    cast(null as integer) as 
    
    usage_limits
    
 , 
    cast(null as TEXT) as 
    
    applies_to
    
 , 
    cast(null as TEXT) as 
    
    applies_to_resource
    
 , 
    cast(null as TEXT) as 
    
    applies_to_product_type
    
 , 
    cast(null as integer) as 
    
    minimum_order_amount
    
 


        
, 'recharge' || '.'|| 'recharge_integration_tests_03' as source_relation

    from base
),

final as (

    select
        source_relation,
        id as discount_id,
        cast(created_at as timestamp) as discount_created_at,
        cast(updated_at as timestamp) as discount_updated_at,
        cast(starts_at as timestamp) as discount_starts_at,
        cast(ends_at as timestamp) as discount_ends_at,
        code,
        value,
        status,
        usage_limits,
        applies_to,
        applies_to_resource,
        applies_to_product_type,
        minimum_order_amount

        





    from fields
)

select *
from final
