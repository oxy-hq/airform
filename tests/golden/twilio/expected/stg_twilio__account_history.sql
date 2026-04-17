with base as (

    select * 
    from "twilio"."main_twilio_source"."stg_twilio__account_history_tmp"
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
    
    owner_account_id
    
 , 
    cast(null as TEXT) as 
    
    status
    
 , 
    cast(null as TEXT) as 
    
    type
    
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
        id as account_id,
        owner_account_id,
        status,
        type,
        updated_at,
        row_number() over (partition by id  order by updated_at desc) = 1 as is_most_recent_record
    from fields
)

select *
from final
