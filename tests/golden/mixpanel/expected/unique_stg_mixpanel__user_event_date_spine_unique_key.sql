select
    unique_key as unique_field,
    count(*) as n_records

from "mixpanel"."main_stg_mixpanel"."stg_mixpanel__user_event_date_spine"
where unique_key is not null
group by unique_key
having count(*) > 1
