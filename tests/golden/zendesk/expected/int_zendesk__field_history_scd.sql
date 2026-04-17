-- model needs to materialize as a table to avoid erroneous null values
 



with change_data as (

    select *
    from "zendesk"."main_zendesk_intermediate"."int_zendesk__field_history_pivot"

), set_values as (

-- each row of the pivoted table includes field values if that field was updated on that day
-- we need to backfill to persist values that have been previously updated and are still valid 
    select 
        source_relation,
        date_day as valid_from,
        ticket_id,
        ticket_day_id

        

    from change_data

), fill_values as (
    select
        source_relation,
        valid_from, 
        ticket_id,
        ticket_day_id

        
    from set_values
) 

select *
from fill_values
