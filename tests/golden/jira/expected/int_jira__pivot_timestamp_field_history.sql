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
),  __dbt__cte__int_jira__issue_multiselect_history as (
with issue_multiselect_history as (

    select *
    from "jira"."main_jira_source"."stg_jira__issue_multiselect_history"
    
), 

fields as (
      
    select *
    from "jira"."main_jira_source"."stg_jira__field"

), 

joined as (

  select
    issue_multiselect_history.*,
    lower(fields.field_name) as field_name,
    cast(date_trunc('week', issue_multiselect_history.updated_at) as date) as updated_at_week

  from issue_multiselect_history
  join fields
    on fields.field_id = issue_multiselect_history.field_id
    and fields.source_relation = issue_multiselect_history.source_relation

)

select *
from joined
), issue_field_history as (

    select *
    from __dbt__cte__int_jira__issue_field_history
),

issue_multiselect_history as (

    select *
    from __dbt__cte__int_jira__issue_multiselect_history
),


sprints as (

    select *
    from "jira"."main_jira_source"."stg_jira__sprint"
),

sprint_name_multiselect_history as (
    -- Create synthetic sprint_name rows by resolving sprint IDs to names (rename field_id to avoid confusion with sprint id)
    select
        'sprint_field' as field_id,
        'sprint_name' as field_name,
        issue_multiselect_history.issue_id,
        issue_multiselect_history.source_relation,
        issue_multiselect_history.updated_at,
        issue_multiselect_history.author_id,
        coalesce(sprints.sprint_name, issue_multiselect_history.field_value) as field_value

    from issue_multiselect_history

    left join sprints
        on cast(sprints.sprint_id as TEXT) = issue_multiselect_history.field_value
        and sprints.source_relation = issue_multiselect_history.source_relation

    where lower(issue_multiselect_history.field_name) = 'sprint'
),


combined_multiselect_history as (
    -- Union original multiselect fields (IDs) with synthetic sprint_name field
    select
        field_id,
        field_name,
        issue_id,
        source_relation,
        updated_at,
        author_id,
        field_value
    from issue_multiselect_history

    
    union all

    select
        field_id,
        field_name,
        issue_id,
        source_relation,
        updated_at,
        author_id,
        field_value
    from sprint_name_multiselect_history
    
),

issue_multiselect_batch_history as (
    -- Aggregate multiselect field values into comma-separated strings
    select
        field_id,
        field_name,
        issue_id,
        source_relation,
        updated_at,
        author_id,
        
    string_agg(field_value, ', ')

 as field_values

    from combined_multiselect_history
    group by 1,2,3,4,5,6
),

combine_field_history as (
    -- Union single-select and multiselect field histories
    select
        field_id,
        issue_id,
        source_relation,
        updated_at,
        author_id,
        field_value,
        field_name
    from issue_field_history

    union all

    select
        field_id,
        issue_id,
        source_relation,
        updated_at,
        author_id,
        field_values as field_value,
        field_name
    from issue_multiselect_batch_history
),

limit_to_relevant_fields as (
    -- Filter to only status and configured custom fields
    select
        combine_field_history.*
    from combine_field_history
    where lower(field_id) = 'status'
        or lower(field_name) in ('sprint', 'sprint_name')
),

int_jira__timestamp_field_history as (
    -- Convert null values to '-is_null' for consistent partitioning
    select
        field_id,
        issue_id,
        source_relation,
        field_name,
        case when field_value is null then '-is_null' else field_value end as field_value,
        updated_at,
        author_id
    from limit_to_relevant_fields
),

final as (
    -- Pivot field values into columns grouped by timestamp
    select
        updated_at,
        issue_id,
        source_relation,
        cast(date_trunc('week', updated_at) as date) as updated_at_week,
        author_id,
        max(case when lower(field_id) = 'status' then field_value end) as status,
        max(case when lower(field_name) = 'sprint' then field_value end) as sprint,
        max(case when lower(field_name) = 'sprint_name' then field_value end) as sprint_name

        from int_jira__timestamp_field_history
    group by 1,2,3,4,5
)

select *
from final
