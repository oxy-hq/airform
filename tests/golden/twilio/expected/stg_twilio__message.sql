with base as (

    select * 
    from "twilio"."main_twilio_source"."stg_twilio__message_tmp"
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
    
    body
    
 , 
    cast(null as timestamp) as 
    
    created_at
    
 , 
    cast(null as timestamp) as 
    
    date_sent
    
 , 
    cast(null as TEXT) as 
    
    direction
    
 , 
    cast(null as TEXT) as 
    
    error_code
    
 , 
    cast(null as TEXT) as 
    
    error_message
    
 , 
    cast(null as TEXT) as 
    
    id
    
 , 
    cast(null as TEXT) as 
    
    messaging_service_sid
    
 , 
    cast(null as TEXT) as 
    
    num_media
    
 , 
    cast(null as TEXT) as 
    
    num_segments
    
 , 
    cast(null as TEXT) as 
    
    price
    
 , 
    cast(null as TEXT) as 
    
    price_unit
    
 , 
    cast(null as TEXT) as 
    
    status
    
 , 
    cast(null as timestamp) as 
    
    updated_at
    
 , 
    cast(null as TEXT) as message_from , 
    cast(null as TEXT) as message_to 


        
, 'twilio' || '.'|| 'twilio_integration_tests' as source_relation

    from base
),

final as (

    select
        source_relation,
        _fivetran_synced,
        account_id,
        body,
        created_at,
        cast(date_sent as timestamp) as timestamp_sent,
        direction,
        error_code,
        error_message,
        message_from, -- renamed in the get_message_columns macro
        id as message_id,
        cast(messaging_service_sid as TEXT) as messaging_service_id,
        cast( 
    REGEXP_REPLACE(cast (num_media as TEXT), '[^0-9.-]', '')
 as float) as num_media,
        cast( 
    REGEXP_REPLACE(cast (num_segments as TEXT), '[^0-9.-]', '')
 as float) as num_segments,
        cast( 
    REGEXP_REPLACE(cast (price as TEXT), '[^0-9.-]', '')
 as float) as price,
        price_unit,
        status,
        message_to, -- renamed in the get_message_columns macro
        updated_at
    from fields
)

select *
from final
