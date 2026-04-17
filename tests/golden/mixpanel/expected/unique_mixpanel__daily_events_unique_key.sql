select
    unique_key as unique_field,
    count(*) as n_records

from "mixpanel"."main_mixpanel"."mixpanel__daily_events"
where unique_key is not null
group by unique_key
having count(*) > 1
