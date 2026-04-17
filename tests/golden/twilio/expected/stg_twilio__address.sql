with base as (

    select * 
    from "twilio"."main_twilio_source"."stg_twilio__address_tmp"
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
    
    city
    
 , 
    cast(null as timestamp) as 
    
    created_at
    
 , 
    cast(null as TEXT) as 
    
    customer_name
    
 , 
    cast(null as boolean) as 
    
    emergency_enabled
    
 , 
    cast(null as TEXT) as 
    
    friendly_name
    
 , 
    cast(null as TEXT) as 
    
    id
    
 , 
    cast(null as TEXT) as 
    
    iso_country
    
 , 
    cast(null as TEXT) as 
    
    postal_code
    
 , 
    cast(null as TEXT) as 
    
    region
    
 , 
    cast(null as TEXT) as 
    
    street
    
 , 
    cast(null as timestamp) as 
    
    updated_at
    
 , 
    cast(null as boolean) as 
    
    validated
    
 , 
    cast(null as boolean) as 
    
    verified
    
 


        
, 'twilio' || '.'|| 'twilio_integration_tests' as source_relation

    from base
),

final as (

    select
        source_relation,
        _fivetran_synced,
        account_id,
        city,
        created_at,
        customer_name,
        emergency_enabled,
        friendly_name,
        cast(id as TEXT) as address_id,
        iso_country,
        postal_code,
        region,
        street,
        updated_at,
        validated,
        verified
    from fields
)

select *
from final
