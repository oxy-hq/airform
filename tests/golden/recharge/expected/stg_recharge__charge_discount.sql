with base as (

    select *
    from "recharge"."main_recharge_source"."stg_recharge__charge_discount_tmp"
),

fields as (

    select
        
    cast(null as integer) as 
    
    charge_id
    
 , 
    cast(null as integer) as 
    
    index
    
 , 
    cast(null as integer) as 
    
    id
    
 , 
    cast(null as TEXT) as 
    
    code
    
 , 
    cast(null as float) as 
    
    value
    
 , 
    cast(null as TEXT) as 
    
    value_type
    
 


        
, 'recharge' || '.'|| 'recharge_integration_tests_03' as source_relation

    from base
),

final as (

    select
        source_relation,
        charge_id,
        index,
        id as discount_id, 
        code,
        cast(value as float) as discount_value,
        value_type
    from fields
)

select *
from final
