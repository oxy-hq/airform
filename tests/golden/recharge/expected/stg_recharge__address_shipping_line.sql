with base as (

    select *
    from "recharge"."main_recharge_source"."stg_recharge__address_shipping_line_tmp"
),

fields as (

    select
        
    cast(null as integer) as 
    
    address_id
    
 , 
    cast(null as integer) as 
    
    index
    
 , 
    cast(null as TEXT) as 
    
    price
    
 , 
    cast(null as TEXT) as 
    
    code
    
 , 
    cast(null as TEXT) as 
    
    title
    
 , 
    cast(null as boolean) as 
    
    _fivetran_deleted
    
 


        
, 'recharge' || '.'|| 'recharge_integration_tests_03' as source_relation

    from base
),

final as (

    select
        source_relation,
        address_id,
        index,
        price,
        code,
        title
    from fields
    where not coalesce(_fivetran_deleted, false)
)

select *
from final
