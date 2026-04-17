with user_first_events as (

    select * 
    from "mixpanel"."main_stg_mixpanel"."stg_mixpanel__user_first_event"
),

spine as (
    
    

    -- Every user-event_type shares the same final date.
    





with rawdata as (

    

    

    with p as (
        select 0 as generated_number union all select 1
    ), unioned as (

    select

    
    p0.generated_number * power(2, 0)
     + 
    
    p1.generated_number * power(2, 1)
     + 
    
    p2.generated_number * power(2, 2)
     + 
    
    p3.generated_number * power(2, 3)
     + 
    
    p4.generated_number * power(2, 4)
     + 
    
    p5.generated_number * power(2, 5)
    
    
    + 1
    as generated_number

    from

    
    p as p0
     cross join 
    
    p as p1
     cross join 
    
    p as p2
     cross join 
    
    p as p3
     cross join 
    
    p as p4
     cross join 
    
    p as p5
    
    

    )

    select *
    from unioned
    where generated_number <= 38
    order by generated_number



),

all_periods as (

    select (
        

    date_add(cast('2026-03-16' as date), interval (row_number() over (order by generated_number) - 1) day)


    ) as date_day
    from rawdata

),

filtered as (

    select *
    from all_periods
    where date_day <= 

    date_add(current_date, interval (1) week)



)

select * from filtered

 
),

user_event_spine as (

    select
        user_first_events.source_relation,
        cast(spine.date_day as date) as date_day,
        user_first_events.people_id,
        user_first_events.event_type,

        -- will use this in mixpanel__daily_events
        case when spine.date_day = user_first_events.first_event_day then 1 else 0 end as is_first_event_day,

        md5(cast(coalesce(cast(user_first_events.people_id as TEXT), '_dbt_utils_surrogate_key_null_') || '-' || coalesce(cast(spine.date_day as TEXT), '_dbt_utils_surrogate_key_null_') || '-' || coalesce(cast(user_first_events.event_type as TEXT), '_dbt_utils_surrogate_key_null_') || '-' || coalesce(cast(user_first_events.source_relation as TEXT), '_dbt_utils_surrogate_key_null_') as TEXT)) as unique_key

    from spine
    join user_first_events
        on spine.date_day >= user_first_events.first_event_day -- each user-event_type will a record for every day since their first day
    group by 1,2,3,4,5,6
    
)

select *
from user_event_spine
