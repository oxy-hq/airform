with  __dbt__cte__int_zendesk__calendar_spine as (
-- depends_on: "zendesk"."main_zendesk_source"."stg_zendesk__ticket"
with spine as (

    

    







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
    where generated_number <= 3765
    order by generated_number



),

all_periods as (

    select (
        

    date_add(cast('2016-01-01' as date), interval (row_number() over (order by generated_number) - 1) day)


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



), recast as (
    select
        cast(date_day as date) as date_day
    from spine
)

select *
from recast
), calendar as (

    select *
    from __dbt__cte__int_zendesk__calendar_spine
    

), ticket as (

    select 
        *,
        -- closed tickets cannot be re-opened or updated, and solved tickets are automatically closed after a pre-defined number of days configured in your Zendesk settings
        cast( date_trunc('day', case when status != 'closed' then now() else updated_at end) as date) as open_until
    from "zendesk"."main_zendesk_source"."stg_zendesk__ticket"
    
), joined as (

    select 
        ticket.source_relation,
        calendar.date_day,
        ticket.ticket_id
    from calendar
    inner join ticket
        on calendar.date_day >= cast(ticket.created_at as date)
        -- use this variable to extend the ticket's history past its close date (for reporting/data viz purposes :-)
        and 

    date_add(ticket.open_until, interval (0) month)

 >= calendar.date_day

), surrogate_key as (

    select
        *,
        md5(cast(coalesce(cast(date_day as TEXT), '_dbt_utils_surrogate_key_null_') || '-' || coalesce(cast(ticket_id as TEXT), '_dbt_utils_surrogate_key_null_') || '-' || coalesce(cast(source_relation as TEXT), '_dbt_utils_surrogate_key_null_') as TEXT)) as ticket_day_id
    from joined

)

select *
from surrogate_key
