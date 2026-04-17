with base as (

    select * 
    from "jira"."main_jira_source"."stg_jira__user_tmp"
),

fields as (

    select
        
    cast(null as timestamp) as 
    
    _fivetran_synced
    
 , 
    cast(null as TEXT) as 
    
    email
    
 , 
    cast(null as TEXT) as 
    
    id
    
 , 
    cast(null as TEXT) as 
    
    locale
    
 , 
    cast(null as TEXT) as 
    
    name
    
 , 
    cast(null as TEXT) as 
    
    time_zone
    
 , 
    cast(null as TEXT) as 
    
    username
    
 , 
    cast(null as boolean) as 
    
    is_active
    
 


        
, 'jira' || '.'|| 'jira_integration_tests' as source_relation

    from base
),

final as (

    select
        source_relation,
        email,
        id as user_id,
        locale,
        name as user_display_name,
        time_zone,
        username,
        is_active,
        _fivetran_synced
    from fields
)

select * 
from final
