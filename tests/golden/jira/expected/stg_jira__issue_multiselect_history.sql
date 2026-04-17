with base as (

    select * 
    from "jira"."main_jira_source"."stg_jira__issue_multiselect_history_tmp"
),

fields as (

    select
        
    cast(null as TEXT) as 
    
    _fivetran_id
    
 , 
    cast(null as timestamp) as 
    
    _fivetran_synced
    
 , 
    cast(null as TEXT) as 
    
    field_id
    
 , 
    cast(null as integer) as 
    
    issue_id
    
 , 
    cast(null as TEXT) as 
    
    value
    
 , 
    cast(null as boolean) as 
    
    is_active
    
 , 
    cast(null as TEXT) as 
    
    author_id
    
 , 
    cast(null as timestamp) as 
    
    time
    
 


        
, 'jira' || '.'|| 'jira_integration_tests' as source_relation

    from base
),

final as (

    select
        source_relation,
        _fivetran_id,
        cast(field_id as TEXT) as field_id,
        issue_id,
        
        cast(time as timestamp)
         as updated_at,
        value as field_value,
        author_id,
        is_active,
        _fivetran_synced
    from fields
)

select * 
from final
