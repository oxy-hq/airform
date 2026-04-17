with change_data as (

    select *
    from "jira"."main_int_jira"."int_jira__pivot_daily_field_history"

), set_values as (

    select
        valid_starting_on,
        issue_id,
        source_relation,
        issue_day_id,
        status as status_id,
        sum( case when status is null then 0 else 1 end) over ( partition by issue_id 
            order by valid_starting_on rows unbounded preceding) as status_id_field_partition

        

    from change_data

), fill_values as (

-- each row of the pivoted table includes field values if that field was updated on that day
-- we need to backfill to persist values that have been previously updated and are still valid
    select
        valid_starting_on,
        issue_id,
        source_relation,
        issue_day_id,
        first_value( status ) over (
            partition by issue_id, status_id_field_partition 
            order by valid_starting_on asc rows between unbounded preceding and current row) as status_id

        

    from set_values

)

select *
from fill_values
