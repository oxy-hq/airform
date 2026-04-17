select
    unique_event_id as unique_field,
    count(*) as n_records

from "amplitude"."main__source_amplitude"."stg_amplitude__event"
where unique_event_id is not null
group by unique_event_id
having count(*) > 1
