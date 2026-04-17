with base as (

    select * 
    from "mailchimp"."main_stg_mailchimp"."stg_mailchimp__automations_tmp"

),

fields as (

    select
        
    cast(null as boolean) as 
    
    _fivetran_deleted
    
 , 
    cast(null as timestamp) as 
    
    _fivetran_synced
    
 , 
    cast(null as timestamp) as 
    
    create_time
    
 , 
    cast(null as TEXT) as 
    
    id
    
 , 
    cast(null as TEXT) as 
    
    list_id
    
 , 
    cast(null as integer) as 
    
    segment_id
    
 , 
    cast(null as integer) as 
    
    segment_text
    
 , 
    cast(null as timestamp) as 
    
    start_time
    
 , 
    cast(null as TEXT) as 
    
    status
    
 , 
    cast(null as TEXT) as 
    
    title
    
 , 
    cast(null as TEXT) as 
    
    trigger_settings
    
 


        
, 'mailchimp' || '.'|| 'mailchimp_integration_tests_2' as source_relation


    from base
),

final as (

    select
        source_relation,
        id as automation_id,
        list_id,
        segment_id, 
        segment_text,
        start_time as started_timestamp,
        create_time as created_timestamp,
        status,
        title,
        trigger_settings
    from fields

)

select *
from final
