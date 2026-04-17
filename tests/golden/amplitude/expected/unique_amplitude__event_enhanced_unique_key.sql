select
    unique_key as unique_field,
    count(*) as n_records

from "amplitude"."main_amplitude"."amplitude__event_enhanced"
where unique_key is not null
group by unique_key
having count(*) > 1
