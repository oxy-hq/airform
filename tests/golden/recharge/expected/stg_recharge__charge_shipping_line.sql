with base as (

    select *
    from "recharge"."main_recharge_source"."stg_recharge__charge_shipping_line_tmp"
),

fields as (

    select
        
    cast(null as integer) as 
    
    charge_id
    
 , 
    cast(null as integer) as 
    
    index
    
 , 
    cast(null as float) as 
    
    price
    
 , 
    cast(null as TEXT) as 
    
    code
    
 , 
    cast(null as TEXT) as 
    
    title
    
 


        
, 'recharge' || '.'|| 'recharge_integration_tests_03' as source_relation

    from base
),

final as (

    select
        source_relation,
        charge_id,
        index,
        price,
        code,
        title
    from fields
)

select *
from final
