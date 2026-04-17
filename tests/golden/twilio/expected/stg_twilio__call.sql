--To disable this model, set the using_twilio_call variable within your dbt_project.yml file to False.


with base as (

    select * 
    from "twilio"."main_twilio_source"."stg_twilio__call_tmp"
),

fields as (

    select
        
    cast(null as timestamp) as 
    
    _fivetran_synced
    
 , 
    cast(null as TEXT) as 
    
    account_id
    
 , 
    cast(null as TEXT) as 
    
    annotation
    
 , 
    cast(null as TEXT) as 
    
    answered_by
    
 , 
    cast(null as TEXT) as 
    
    caller_name
    
 , 
    cast(null as timestamp) as 
    
    created_at
    
 , 
    cast(null as TEXT) as 
    
    direction
    
 , 
    cast(null as TEXT) as 
    
    duration
    
 , 
    cast(null as timestamp) as 
    
    end_time
    
 , 
    cast(null as TEXT) as 
    
    forwarded_from
    
 , 
    cast(null as TEXT) as 
    
    from_formatted
    
 , 
    cast(null as TEXT) as 
    
    group_id
    
 , 
    cast(null as TEXT) as 
    
    id
    
 , 
    cast(null as TEXT) as 
    
    outgoing_caller_id
    
 , 
    cast(null as TEXT) as 
    
    parent_call_id
    
 , 
    cast(null as TEXT) as 
    
    price
    
 , 
    cast(null as TEXT) as 
    
    price_unit
    
 , 
    cast(null as TEXT) as 
    
    queue_time
    
 , 
    cast(null as timestamp) as 
    
    start_time
    
 , 
    cast(null as TEXT) as 
    
    status
    
 , 
    cast(null as TEXT) as 
    
    to_formatted
    
 , 
    cast(null as TEXT) as 
    
    trunk_id
    
 , 
    cast(null as timestamp) as 
    
    updated_at
    
 , 
    cast(null as TEXT) as call_from , 
    cast(null as TEXT) as call_to 


        
, 'twilio' || '.'|| 'twilio_integration_tests' as source_relation

    from base
),

final as (

    select
        source_relation,
        _fivetran_synced,
        account_id,
        annotation,
        answered_by,
        caller_name,
        created_at,
        direction,
        cast( 
    REGEXP_REPLACE(cast (duration as TEXT), '[^0-9.-]', '')
 as float) as duration,
        end_time,
        forwarded_from,
        call_from, -- renamed in the get_call_columns macro
        from_formatted,
        group_id,
        id as call_id,
        outgoing_caller_id,
        parent_call_id,
        cast( 
    REGEXP_REPLACE(cast (price as TEXT), '[^0-9.-]', '')
 as float) as price,
        price_unit,
        cast( 
    REGEXP_REPLACE(cast (queue_time as TEXT), '[^0-9.-]', '')
 as float) as queue_time,
        start_time,
        status,
        call_to, -- renamed in the get_call_columns macro
        to_formatted,
        trunk_id,
        updated_at
    from fields
)

select *
from final
