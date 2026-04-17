with base as (

    select * 
    from "twilio"."main_twilio_source"."stg_twilio__outgoing_caller_id_tmp"
),

fields as (

    select
        
    cast(null as timestamp) as 
    
    _fivetran_synced
    
 , 
    cast(null as timestamp) as 
    
    created_at
    
 , 
    cast(null as TEXT) as 
    
    friendly_name
    
 , 
    cast(null as TEXT) as 
    
    id
    
 , 
    cast(null as TEXT) as 
    
    phone_number
    
 , 
    cast(null as timestamp) as 
    
    updated_at
    
 


        
, 'twilio' || '.'|| 'twilio_integration_tests' as source_relation

    from base
),

final as (

    select
        source_relation,
        _fivetran_synced,
        created_at,
        friendly_name,
        id as outgoing_caller_id,
        phone_number,
        updated_at
    from fields
)

select *
from final
