select
    daily_unique_key as unique_field,
    count(*) as n_records

from "amplitude"."main_amplitude"."amplitude__daily_performance"
where daily_unique_key is not null
group by daily_unique_key
having count(*) > 1
