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
),  __dbt__cte__int_jira__pivot_timestamp_field_history as (
with issue_field_history as (

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
),  __dbt__cte__int_jira__timestamp_field_history_scd as (
with change_data as (

    select *
    from __dbt__cte__int_jira__pivot_timestamp_field_history

), set_values as (
    -- Create partitions to group consecutive null values for forward-filling
    select
        updated_at,
        issue_id,
        source_relation,
        updated_at_week,
        author_id,
        status,
        sum( case when status is null then 0 else 1 end) over ( partition by issue_id 
            order by updated_at rows unbounded preceding) as status_field_partition
        , sprint
        , sum( case when sprint is null then 0 else 1 end) over ( partition by issue_id 
            order by updated_at rows unbounded preceding) as sprint_field_partition
        , sprint_name
        , sum( case when sprint_name is null then 0 else 1 end) over ( partition by issue_id 
            order by updated_at rows unbounded preceding) as sprint_name_field_partition

        

    from change_data

), fill_values as (
    -- Forward-fill values within each partition to create SCD Type 2 records
    select
        updated_at,
        issue_id,
        source_relation,
        updated_at_week,
        author_id,
        first_value( status ) over (
            partition by issue_id, status_field_partition 
            order by updated_at asc rows between unbounded preceding and current row) as status
        , first_value( sprint ) over (
            partition by issue_id, sprint_field_partition 
            order by updated_at asc rows between unbounded preceding and current row) as sprint
        , first_value( sprint_name ) over (
            partition by issue_id, sprint_name_field_partition 
            order by updated_at asc rows between unbounded preceding and current row) as sprint_name

        

    from set_values

)

select *
from fill_values
), timestamp_history_scd as (

    select *
    from __dbt__cte__int_jira__timestamp_field_history_scd
),

statuses as (

    select *
    from "jira"."main_jira_source"."stg_jira__status"
),

status_categories as (

    select *
    from "jira"."main_jira_source"."stg_jira__status_category"
),

issue_types as (

    select *
    from "jira"."main_jira_source"."stg_jira__issue_type"
),


components as (

    select *
    from "jira"."main_jira_source"."stg_jira__component"
),


projects as (

    select *
    from "jira"."main_jira_source"."stg_jira__project"
),

users as (

    select *
    from "jira"."main_jira_source"."stg_jira__user"
),


teams as (

    select *
    from "jira"."main_jira_source"."stg_jira__team"
),


field_option as (

    select *
    from "jira"."main_jira_source"."stg_jira__field_option"
),

create_validity_periods as (
    -- Create SCD Type 2 validity periods using lead() window function
    select
        updated_at as valid_from,
        -- Next update becomes valid_until for this record
        lead(updated_at) over (
            partition by issue_id 
            order by updated_at
        ) as valid_until,
        updated_at_week,
        issue_id,
        source_relation,
        status as status_id,
        author_id,
        sprint,
        sprint_name
        
        

        -- list of exception columns
        

        

    from timestamp_history_scd
),

fix_null_values as (

    select
        create_validity_periods.valid_from,
        coalesce(create_validity_periods.valid_until, now()) as valid_until,
        create_validity_periods.updated_at_week,
        create_validity_periods.issue_id,
        create_validity_periods.source_relation,
        create_validity_periods.status_id,
        statuses.status_name as status,
        status_categories.status_category_name,
        create_validity_periods.author_id,
        case when create_validity_periods.sprint = '-is_null' then null else create_validity_periods.sprint end as sprint,
        case when create_validity_periods.sprint_name = '-is_null' then null else create_validity_periods.sprint_name end as sprint_name
        
        

        -- list of exception columns
        

        

        , case when create_validity_periods.valid_until is null then true else false end as is_current_record

    from create_validity_periods

    left join statuses
        on cast(statuses.status_id as TEXT) = create_validity_periods.status_id
        and statuses.source_relation = create_validity_periods.source_relation

    left join status_categories
        on statuses.status_category_id = status_categories.status_category_id
        and statuses.source_relation = status_categories.source_relation
),

final as (
    -- Resolve field values using lookup tables and add surrogate key
    select
        fix_null_values.valid_from,
        coalesce(fix_null_values.valid_until, now()) as valid_until,
        fix_null_values.updated_at_week,
        fix_null_values.issue_id,
        fix_null_values.source_relation,
        fix_null_values.status_id,
        fix_null_values.status,
        fix_null_values.status_category_name,
        fix_null_values.author_id,
        fix_null_values.sprint,
        fix_null_values.sprint_name
        
        

        

        , fix_null_values.is_current_record
        , md5(cast(coalesce(cast(fix_null_values.valid_from as TEXT), '_dbt_utils_surrogate_key_null_') || '-' || coalesce(cast(fix_null_values.issue_id as TEXT), '_dbt_utils_surrogate_key_null_') || '-' || coalesce(cast(fix_null_values.source_relation as TEXT), '_dbt_utils_surrogate_key_null_') as TEXT)) as issue_timestamp_id

    from fix_null_values

    
)

select *
from final
