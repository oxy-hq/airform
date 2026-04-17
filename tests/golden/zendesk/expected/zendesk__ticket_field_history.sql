with change_data as (

    select *
    from "zendesk"."main_zendesk_intermediate"."int_zendesk__field_history_scd"
  
    

), calendar as (

    select *
    from "zendesk"."main_zendesk_intermediate"."int_zendesk__field_calendar_spine"
    where date_day <= current_date
    

), joined as (

    select 
        calendar.source_relation,
        calendar.date_day,
        calendar.ticket_id
        
            
        

    from calendar
    left join change_data
        on calendar.ticket_id = change_data.ticket_id
        and calendar.date_day = change_data.valid_from
        and calendar.source_relation = change_data.source_relation
    
    

), set_values as (

    select
        source_relation,
        date_day,
        ticket_id

        

    from joined
),

fill_values as (

    select  
        source_relation,
        date_day,
        ticket_id

        

    from set_values

), fix_null_values as (

    select  
        source_relation, 
        date_day,
        ticket_id
        

    from fill_values

), surrogate_key as (

    select
        md5(cast(coalesce(cast(source_relation as TEXT), '_dbt_utils_surrogate_key_null_') || '-' || coalesce(cast(date_day as TEXT), '_dbt_utils_surrogate_key_null_') || '-' || coalesce(cast(ticket_id as TEXT), '_dbt_utils_surrogate_key_null_') as TEXT)) as ticket_day_id,
        *

    from fix_null_values
)

select *
from surrogate_key
