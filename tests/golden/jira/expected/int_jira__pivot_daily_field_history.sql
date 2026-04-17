-- issue_multiselect_history splits out an array-type field into multiple rows with unique individual values
-- to combine with issue_field_history we need to aggregate the multiselect field values.

-- Hardcode 'team' into the issue_field_history_columns list if not already present



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
    -- Create synthetic sprint_name rows by resolving sprint IDs to names
    select
        'sprint_field' as field_id,
        'sprint_name' as field_name,
        issue_multiselect_history.issue_id,
        issue_multiselect_history.source_relation,
        issue_multiselect_history.updated_at,
        issue_multiselect_history.updated_at_week,
        cast(date_trunc('day', issue_multiselect_history.updated_at) as date) as date_day,
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
        updated_at_week,
        cast(date_trunc('day', updated_at) as date) as date_day,
        field_value
    from issue_multiselect_history

    
    union all

    select
        field_id,
        field_name,
        issue_id,
        source_relation,
        updated_at,
        updated_at_week,
        date_day,
        field_value
    from sprint_name_multiselect_history
    
),

issue_multiselect_batch_history as (

    select
        field_id,
        field_name,
        issue_id,
        source_relation,
        updated_at,
        updated_at_week,
        date_day,
        
    string_agg(field_value, ', ')

 as field_values

    from combined_multiselect_history

    group by 1,2,3,4,5,6,7
),

combine_field_history as (
-- combining all the field histories together
    select
        field_id,
        issue_id,
        source_relation,
        updated_at,
        updated_at_week,
        field_value,
        field_name

    from issue_field_history

    union all

    select
        field_id,
        issue_id,
        source_relation,
        updated_at,
        updated_at_week,
        field_values as field_value, -- this is an aggregated list but we'll just call it field_value
        field_name

    from issue_multiselect_batch_history
),

get_valid_dates as (

    select
        field_id,
        issue_id,
        source_relation,
        field_value,
        field_name,
        updated_at as valid_starting_at,
        updated_at_week as valid_starting_at_week,

        -- this value is valid until the next value is updated
        lead(updated_at, 1) over(partition by issue_id, field_id  order by updated_at asc) as valid_ending_at,
        cast( date_trunc('day', updated_at) as date) as valid_starting_on

    from combine_field_history
),

limit_to_relevant_fields as (
    -- let's remove unnecessary rows moving forward and grab field names
    select
        get_valid_dates.*

    from get_valid_dates

    where lower(field_id) = 'status'
        or lower(field_name) in ('sprint', 'sprint_name','team')
),

order_daily_values as (

    select
        *,
        -- want to grab last value for an issue's field for each day
        row_number() over (
            partition by valid_starting_on, issue_id, field_id 
            order by valid_starting_at desc
            ) as row_num

    from limit_to_relevant_fields
),

-- only looking at the latest value for each day
get_latest_daily_value as (

    select * 

    from order_daily_values
    where row_num = 1
), 

int_jira__daily_field_history as (

    select
        field_id,
        issue_id,
        source_relation,
        field_name,

        -- doing this to figure out what values are actually null and what needs to be backfilled in jira__daily_issue_field_history
        case when field_value is null then '-is_null' else field_value end as field_value,
        valid_starting_at,
        valid_starting_at_week,
        valid_ending_at,
        valid_starting_on

    from get_latest_daily_value
),

pivot_out as (

    -- pivot out default columns (status, sprint, sprint_name) and others specified in the var(issue_field_history_columns)
    -- only days on which a field value was actively changed will have a non-null value. the nulls will need to
    -- be backfilled in the final jira__daily_issue_field_history model
    select
        valid_starting_on,
        issue_id,
        source_relation,
        valid_starting_at_week,
        max(case when lower(field_id) = 'status' then field_value end) as status,
        max(case when lower(field_name) = 'sprint' then field_value end) as sprint,
        max(case when lower(field_name) = 'sprint_name' then field_value end) as sprint_name

        
            , max(case when lower(field_name) = 'team' then field_value end) as team
        
        from int_jira__daily_field_history

    group by 1,2,3,4
),

final as (
    select
        *,
        md5(cast(coalesce(cast(valid_starting_on as TEXT), '_dbt_utils_surrogate_key_null_') || '-' || coalesce(cast(issue_id as TEXT), '_dbt_utils_surrogate_key_null_') || '-' || coalesce(cast(source_relation as TEXT), '_dbt_utils_surrogate_key_null_') as TEXT)) as issue_day_id

    from pivot_out
)

select *
from final
