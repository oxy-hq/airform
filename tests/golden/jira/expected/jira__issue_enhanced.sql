with issue as (

    select *
    from "jira"."main_int_jira"."int_jira__issue_join"
),daily_issue_field_history as (

    select
        *,
        row_number() over (partition by issue_id  order by date_day desc) = 1 as latest_record
    from "jira"."main_jira"."jira__daily_issue_field_history"

),

latest_issue_field_history as (
    
    select *
    from daily_issue_field_history
    where latest_record
),

final as (

    select 
    
        issue.*,
        date_diff('second', created_at::timestamp, coalesce(resolved_at, now())::timestamp ) open_duration_seconds,
        -- this will be null if no one has been assigned
        date_diff('second', first_assigned_at::timestamp, coalesce(resolved_at, now())::timestamp ) any_assignment_duration_seconds,
        -- if an issue is not currently assigned this will not be null
        date_diff('second', last_assigned_at::timestamp, coalesce(resolved_at, now())::timestamp ) last_assignment_duration_seconds 

        

    from issue
    left join latest_issue_field_history
        on issue.issue_id = latest_issue_field_history.issue_id
        and issue.source_relation = latest_issue_field_history.source_relation
        
)

select *
from final
