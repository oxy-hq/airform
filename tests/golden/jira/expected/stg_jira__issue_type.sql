with base as (

    select * from 
    "jira"."main_jira_source"."stg_jira__issue_type_tmp"
),

fields as (

    select
        
    cast(null as timestamp) as 
    
    _fivetran_synced
    
 , 
    cast(null as TEXT) as 
    
    description
    
 , 
    cast(null as integer) as 
    
    id
    
 , 
    cast(null as TEXT) as 
    
    name
    
 , 
    cast(null as boolean) as 
    
    subtask
    
 


        
, 'jira' || '.'|| 'jira_integration_tests' as source_relation

    from base
),

final as (

    select
        source_relation,
        description,
        id as issue_type_id,
        name as issue_type_name,
        subtask as is_subtask,
        _fivetran_synced
    from fields
)

select * 
from final
