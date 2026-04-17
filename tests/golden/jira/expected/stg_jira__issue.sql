with base as (
    
    select * 
    from "jira"."main_jira_source"."stg_jira__issue_tmp"
),

fields as (

    select
        
    cast(null as boolean) as 
    
    _fivetran_deleted
    
 , 
    cast(null as timestamp) as 
    
    _fivetran_synced
    
 , 
    cast(null as float) as 
    
    _original_estimate
    
 , 
    cast(null as float) as 
    
    _remaining_estimate
    
 , 
    cast(null as float) as 
    
    _time_spent
    
 , 
    cast(null as TEXT) as 
    
    assignee
    
 , 
    cast(null as timestamp) as 
    
    created
    
 , 
    cast(null as TEXT) as 
    
    creator
    
 , 
    cast(null as TEXT) as 
    
    description
    
 , 
    cast(null as date) as 
    
    due_date
    
 , 
    cast(null as TEXT) as 
    
    environment
    
 , 
    cast(null as integer) as 
    
    id
    
 , 
    cast(null as integer) as 
    
    issue_type
    
 , 
    cast(null as integer) as 
    
    work_type
    
 , 
    cast(null as TEXT) as 
    
    key
    
 , 
    cast(null as float) as 
    
    original_estimate
    
 , 
    cast(null as integer) as 
    
    parent_id
    
 , 
    cast(null as integer) as 
    
    priority
    
 , 
    cast(null as integer) as 
    
    project
    
 , 
    cast(null as float) as 
    
    remaining_estimate
    
 , 
    cast(null as TEXT) as 
    
    reporter
    
 , 
    cast(null as integer) as 
    
    resolution
    
 , 
    cast(null as timestamp) as 
    
    resolved
    
 , 
    cast(null as integer) as 
    
    status
    
 , 
    cast(null as timestamp) as 
    
    status_category_changed
    
 , 
    cast(null as TEXT) as 
    
    summary
    
 , 
    cast(null as float) as 
    
    time_spent
    
 , 
    cast(null as timestamp) as 
    
    updated
    
 , 
    cast(null as float) as 
    
    work_ratio
    
 


        
, 'jira' || '.'|| 'jira_integration_tests' as source_relation

    from base
),

final as (

    select
        source_relation,
        coalesce(original_estimate, _original_estimate) as original_estimate_seconds,
        coalesce(remaining_estimate, _remaining_estimate) as remaining_estimate_seconds,
        coalesce(time_spent, _time_spent) as time_spent_seconds,
        assignee as assignee_user_id,
        cast(created as timestamp) as created_at,
        cast(resolved  as timestamp) as resolved_at,
        creator as creator_user_id,
        description as issue_description,
        due_date,
        environment,
        id as issue_id,
        coalesce(work_type, issue_type) as issue_type_id,
        key as issue_key,
        parent_id as parent_issue_id,
        priority as priority_id,
        project as project_id,
        reporter as reporter_user_id,
        resolution as resolution_id,
        status as status_id,
        cast(status_category_changed as timestamp) as status_changed_at,
        summary as issue_name,
        cast(updated as timestamp) as updated_at,
        work_ratio,
        _fivetran_synced
    from fields
    where not coalesce(_fivetran_deleted, false)
)

select * 
from final
