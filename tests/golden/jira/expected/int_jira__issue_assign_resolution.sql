with  __dbt__cte__int_jira__issue_field_history as (
with field_history as (

    select *
    from "jira"."main_jira_source"."stg_jira__issue_field_history"
    
), 

fields as (
      
    select *
    from "jira"."main_jira_source"."stg_jira__field"

), 

joined as (

  select
    field_history.*,
    lower(fields.field_name) as field_name,
    cast(date_trunc('week', field_history.updated_at) as date) as updated_at_week

  from field_history
  join fields
    on fields.field_id = field_history.field_id
    and fields.source_relation = field_history.source_relation

)

select *
from joined
), issue_field_history as (
    
    select *
    from __dbt__cte__int_jira__issue_field_history
),

filtered as (
    -- we're only looking at assignments and resolutions, which are single-field values
    select *
    from issue_field_history
    where (lower(field_id) = 'assignee'
        or lower(field_id) = 'resolutiondate')
        and field_value is not null -- remove initial null rows
),

issue_dates as (

    select
        issue_id,
        source_relation,
        min(case when field_id = 'assignee' then updated_at end) as first_assigned_at,
        max(case when field_id = 'assignee' then updated_at end) as last_assigned_at,
        min(case when field_id = 'resolutiondate' then updated_at end) as first_resolved_at -- in case it's been re-opened
    from filtered
    group by 1, 2
)

select *
from issue_dates
