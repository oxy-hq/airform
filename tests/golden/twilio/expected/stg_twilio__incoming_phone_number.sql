with base as (

    select * 
    from "twilio"."main_twilio_source"."stg_twilio__incoming_phone_number_tmp"
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
    
    address_id
    
 , 
    cast(null as TEXT) as 
    
    address_requirements
    
 , 
    cast(null as boolean) as 
    
    beta
    
 , 
    cast(null as boolean) as 
    
    capabilities_mms
    
 , 
    cast(null as boolean) as 
    
    capabilities_sms
    
 , 
    cast(null as boolean) as 
    
    capabilities_voice
    
 , 
    cast(null as timestamp) as 
    
    created_at
    
 , 
    cast(null as TEXT) as 
    
    emergency_address_id
    
 , 
    cast(null as TEXT) as 
    
    emergency_status
    
 , 
    cast(null as TEXT) as 
    
    friendly_name
    
 , 
    cast(null as TEXT) as 
    
    id
    
 , 
    cast(null as TEXT) as 
    
    origin
    
 , 
    cast(null as TEXT) as 
    
    phone_number
    
 , 
    cast(null as TEXT) as 
    
    trunk_id
    
 , 
    cast(null as timestamp) as 
    
    updated_at
    
 , 
    cast(null as boolean) as 
    
    voice_caller_id_lookup
    
 , 
    cast(null as TEXT) as 
    
    voice_url
    
 


        
, 'twilio' || '.'|| 'twilio_integration_tests' as source_relation

    from base
),

final as (

    select
        source_relation,
        _fivetran_synced,
        account_id,
        cast(address_id as TEXT) as address_id,
        capabilities_mms,
        capabilities_sms,
        capabilities_voice,
        created_at,
        emergency_address_id,
        emergency_status,
        friendly_name,
        id as incoming_phone_number_id,
        origin,
        phone_number,
        trunk_id,
        updated_at,
        voice_caller_id_lookup,
        voice_url
    from fields
)

select *
from final
