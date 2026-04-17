with base as (

    select * 
    from "jira"."main_jira_source"."stg_jira__version_tmp"
),

fields as (

    select
        
    cast(null as timestamp) as 
    
    _fivetran_synced
    
 , 
    cast(null as boolean) as 
    
    archived
    
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
    
    overdue
    
 , 
    cast(null as integer) as 
    
    project_id
    
 , 
    cast(null as date) as 
    
    release_date
    
 , 
    cast(null as boolean) as 
    
    released
    
 , 
    cast(null as date) as 
    
    start_date
    
 


        
, 'jira' || '.'|| 'jira_integration_tests' as source_relation

    from base
),

final as (

    select
        source_relation,
        archived as is_archived,
        description,
        id as version_id,
        name as version_name,
        overdue as is_overdue,
        project_id,
        cast(release_date as timestamp) as release_date,
        released as is_released,
        cast(start_date as timestamp) as start_date
    from fields
)

select * 
from final
