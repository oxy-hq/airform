with base as (

    select * 
    from "jira"."main_jira_source"."stg_jira__component_tmp"
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
    cast(null as integer) as 
    
    project_id
    
 


        
, 'jira' || '.'|| 'jira_integration_tests' as source_relation

    from base
),

final as (

    select
        source_relation,
        description as component_description,
        id as component_id,
        name as component_name,
        project_id,
        _fivetran_synced
    from fields
)

select * 
from final
