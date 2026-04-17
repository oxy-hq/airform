with  __dbt__cte__int_amplitude__date_spine as (


with spine as (


    select
        cast(spine.date_day as date) as date_day
    from (
        





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
     + 
    
    p6.generated_number * power(2, 6)
     + 
    
    p7.generated_number * power(2, 7)
     + 
    
    p8.generated_number * power(2, 8)
     + 
    
    p9.generated_number * power(2, 9)
     + 
    
    p10.generated_number * power(2, 10)
     + 
    
    p11.generated_number * power(2, 11)
    
    
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
     cross join 
    
    p as p6
     cross join 
    
    p as p7
     cross join 
    
    p as p8
     cross join 
    
    p as p9
     cross join 
    
    p as p10
     cross join 
    
    p as p11
    
    

    )

    select *
    from unioned
    where generated_number <= 2298
    order by generated_number



),

all_periods as (

    select (
        

    date_add(cast('2020-01-01' as date), interval (row_number() over (order by generated_number) - 1) day)


    ) as date_day
    from rawdata

),

filtered as (

    select *
    from all_periods
    where date_day <= cast('2026-04-17' as date)

)

select * from filtered

 
    ) as spine
)

select * 
from spine
), event_enhanced as (

    select * 
    from "amplitude"."main_amplitude"."amplitude__event_enhanced"
),

date_spine as (

    select distinct 
        event_enhanced.source_relation,
        event_enhanced.event_type,
        spine.date_day as event_day
    from __dbt__cte__int_amplitude__date_spine as spine
    join event_enhanced -- this join limits the incremental run
        on spine.date_day >= event_enhanced.event_day -- each event_type will have a record for every day since their first day

    
), 

agg_event_data as (

    select
        source_relation,
        event_day,
        event_type,
        count(distinct unique_event_id) as number_events,
        count(distinct unique_session_id) as number_sessions,
        count(distinct amplitude_user_id) as number_users,
        count(distinct
                (case when cast( date_trunc('day', user_creation_time) as date) = event_day
            then amplitude_user_id end)) as number_new_users
    from event_enhanced
    group by 1,2,3
),

final as (
    select
        date_spine.source_relation,
        date_spine.event_day,
        date_spine.event_type,
        coalesce(agg_event_data.number_events, 0) as number_events,
        coalesce(agg_event_data.number_sessions, 0) as number_sessions,
        coalesce(agg_event_data.number_users, 0) as number_users,
        coalesce(agg_event_data.number_new_users, 0) as number_new_users,
        md5(cast(coalesce(cast(date_spine.source_relation as TEXT), '_dbt_utils_surrogate_key_null_') || '-' || coalesce(cast(date_spine.event_day as TEXT), '_dbt_utils_surrogate_key_null_') || '-' || coalesce(cast(date_spine.event_type as TEXT), '_dbt_utils_surrogate_key_null_') as TEXT)) as daily_unique_key
    from date_spine
    left join agg_event_data
        on date_spine.source_relation = agg_event_data.source_relation
        and date_spine.event_day = agg_event_data.event_day
        and date_spine.event_type = agg_event_data.event_type
)

select *
from final
