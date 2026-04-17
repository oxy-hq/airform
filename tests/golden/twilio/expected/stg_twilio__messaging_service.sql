--To disable this model, set the using_twilio_messaging_service variable within your dbt_project.yml file to False.


with base as (

    select * 
    from "twilio"."main_twilio_source"."stg_twilio__messaging_service_tmp"
),

fields as (

    select
        
    cast(null as boolean) as 
    
    _fivetran_deleted
    
 , 
    cast(null as timestamp) as 
    
    _fivetran_synced
    
 , 
    cast(null as TEXT) as 
    
    account_id
    
 , 
    cast(null as boolean) as 
    
    area_code_geomatch
    
 , 
    cast(null as timestamp) as 
    
    created_at
    
 , 
    cast(null as TEXT) as 
    
    fallback_method
    
 , 
    cast(null as boolean) as 
    
    fallback_to_long_code
    
 , 
    cast(null as TEXT) as 
    
    fallback_url
    
 , 
    cast(null as TEXT) as 
    
    friendly_name
    
 , 
    cast(null as TEXT) as 
    
    id
    
 , 
    cast(null as TEXT) as 
    
    inbound_method
    
 , 
    cast(null as TEXT) as 
    
    inbound_request_url
    
 , 
    cast(null as boolean) as 
    
    mms_converter
    
 , 
    cast(null as TEXT) as 
    
    scan_message_content
    
 , 
    cast(null as boolean) as 
    
    smart_encoding
    
 , 
    cast(null as TEXT) as 
    
    status_callback
    
 , 
    cast(null as boolean) as 
    
    sticky_sender
    
 , 
    cast(null as boolean) as 
    
    synchronous_validation
    
 , 
    cast(null as timestamp) as 
    
    updated_at
    
 , 
    cast(null as boolean) as 
    
    us_app_to_person_registered
    
 , 
    cast(null as boolean) as 
    
    use_inbound_webhook_on_number
    
 , 
    cast(null as TEXT) as 
    
    usecase
    
 , 
    cast(null as integer) as 
    
    validity_period
    
 


        
, 'twilio' || '.'|| 'twilio_integration_tests' as source_relation

    from base
),

final as (

    select
        source_relation,
        _fivetran_deleted,
        _fivetran_synced,
        account_id,
        area_code_geomatch,
        created_at,
        fallback_method,
        fallback_to_long_code,
        fallback_url,
        friendly_name,
        cast(id as TEXT) as messaging_service_id,
        inbound_method,
        inbound_request_url,
        mms_converter,
        scan_message_content,
        smart_encoding,
        status_callback,
        sticky_sender,
        synchronous_validation,
        updated_at,
        us_app_to_person_registered,
        use_inbound_webhook_on_number,
        usecase as use_case,
        validity_period
    from fields
)

select *
from final
