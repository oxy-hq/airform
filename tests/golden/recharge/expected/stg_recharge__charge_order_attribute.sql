with base as (

    select *
    from "recharge"."main_recharge_source"."stg_recharge__charge_order_attribute_tmp"
),

fields as (

    select
        
    cast(null as integer) as 
    
    charge_id
    
 , 
    cast(null as integer) as 
    
    index
    
 , 
    cast(null as TEXT) as 
    
    order_attribute
    
 


        
, 'recharge' || '.'|| 'recharge_integration_tests_03' as source_relation

    from base
),

final as (

    select
        source_relation,
        charge_id,
        index,
        order_attribute
    from fields
)

select *
from final
