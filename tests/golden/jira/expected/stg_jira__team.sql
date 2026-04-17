with base as (

    select * 
    from "jira"."main_jira_source"."stg_jira__team_tmp"
),

fields as (

    select
        
    cast(null as timestamp) as 
    
    _fivetran_synced
    
 , 
    cast(null as TEXT) as 
    
    id
    
 , 
    cast(null as boolean) as 
    
    is_shared
    
 , 
    cast(null as boolean) as 
    
    is_visible
    
 , 
    cast(null as TEXT) as 
    
    name
    
 , 
    cast(null as TEXT) as 
    
    title
    
 


        
, 'jira' || '.'|| 'jira_integration_tests' as source_relation

    from base
),

final as (

    select
        source_relation,
        cast(id as TEXT) as team_id,
        is_shared as is_shared_team,
        is_visible as is_visible_team,
        name as team_name,
        title as team_title,
        _fivetran_synced
    from fields
)

select * 
from final
