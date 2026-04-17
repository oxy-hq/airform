with base as (

    select *
    from "mailchimp"."main_stg_mailchimp"."stg_mailchimp__automation_activities_tmp"

), 

fields as (

    select
        
    cast(null as timestamp) as 
    
    _fivetran_synced
    
 , 
    cast(null as TEXT) as 
    
    action
    
 , 
    cast(null as TEXT) as 
    
    automation_email_id
    
 , 
    cast(null as integer) as 
    
    bounce_type
    
 , 
    cast(null as TEXT) as 
    
    ip
    
 , 
    cast(null as TEXT) as 
    
    list_id
    
 , 
    cast(null as TEXT) as 
    
    member_id
    
 , 
    cast(null as timestamp) as 
    
    timestamp
    
 , 
    cast(null as TEXT) as 
    
    url
    
 


        
, 'mailchimp' || '.'|| 'mailchimp_integration_tests_2' as source_relation


    from base

), 

final as (

    select
        source_relation,
        action as action_type,
        automation_email_id,
        member_id,
        list_id,
        timestamp as activity_timestamp,
        ip as ip_address,
        url,
        bounce_type
    from fields

),

unique_key as (

    select
        *,
        md5(cast(coalesce(cast(source_relation as TEXT), '_dbt_utils_surrogate_key_null_') || '-' || coalesce(cast(action_type as TEXT), '_dbt_utils_surrogate_key_null_') || '-' || coalesce(cast(automation_email_id as TEXT), '_dbt_utils_surrogate_key_null_') || '-' || coalesce(cast(member_id as TEXT), '_dbt_utils_surrogate_key_null_') || '-' || coalesce(cast(activity_timestamp as TEXT), '_dbt_utils_surrogate_key_null_') as TEXT)) as activity_id
    from final
)

select * from unique_key
