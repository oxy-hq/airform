with base as (

    select *
    from "jira"."main_jira_source"."stg_jira__sprint_tmp"
),

fields as (

    select
        
    cast(null as boolean) as 
    
    _fivetran_deleted
    
 , 
    cast(null as timestamp) as 
    
    _fivetran_synced
    
 , 
    cast(null as integer) as 
    
    board_id
    
 , 
    cast(null as timestamp) as 
    
    complete_date
    
 , 
    cast(null as timestamp) as 
    
    end_date
    
 , 
    cast(null as integer) as 
    
    id
    
 , 
    cast(null as TEXT) as 
    
    name
    
 , 
    cast(null as timestamp) as 
    
    start_date
    
 


        
, 'jira' || '.'|| 'jira_integration_tests' as source_relation

    from base
),

final as (

    select
        source_relation,
        id as sprint_id,
        name as sprint_name,
        board_id,
        cast(complete_date as timestamp) as completed_at,
        cast(end_date as timestamp) as ended_at,
        cast(start_date as timestamp) as started_at,
        _fivetran_synced
    from fields
    where not coalesce(_fivetran_deleted, false)
)

select * 
from final
