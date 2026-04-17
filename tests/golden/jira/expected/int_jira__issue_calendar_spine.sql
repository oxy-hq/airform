with spine as (

    -- depends_on: "jira"."main_jira_source"."stg_jira__issue_tmp"
     
    

    select
        cast(date_day as date) as date_day
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

    date_add(now(), interval (1) week)



)

select * from filtered


    ) as date_spine
),

issue_history_scd as (
    
    select *
    from "jira"."main_int_jira"."int_jira__field_history_scd"
),

issue_dates as (

    select
        issue_history_scd.issue_id,
        issue_history_scd.source_relation,
        cast( date_trunc('day', issue.created_at) as date) as created_on,
        -- resolved_at will become null if an issue is marked as un-resolved. if this sorta thing happens often, you may want to run full-refreshes of the field_history models often
        -- if it's not resolved include everything up to today. if it is, look at the last time it was updated
        cast(date_trunc('day', case when issue.resolved_at is null then now() else cast(issue_history_scd.valid_starting_on as timestamp) end)
            as date) as open_until
    from issue_history_scd
    left join "jira"."main_jira_source"."stg_jira__issue" as issue
        on issue_history_scd.issue_id = issue.issue_id
        and issue_history_scd.source_relation = issue.source_relation
),

issue_spine as (

    select
        spine.date_day,
        issue_dates.issue_id,
        issue_dates.source_relation,
        -- will take the table-wide min of this in the incremental block at the top of this model
        min(issue_dates.open_until) as earliest_open_until_date

    from spine
    join issue_dates on
        issue_dates.created_on <= spine.date_day
        and 

    date_add(issue_dates.open_until, interval (1) month)

 >= spine.date_day
        -- if we cut off issues, we're going to have to do a full refresh to catch issues that have been un-resolved
    group by 1,2,3
),

surrogate_key as (

    select
        date_day,
        issue_id,
        source_relation,
        md5(cast(coalesce(cast(date_day as TEXT), '_dbt_utils_surrogate_key_null_') || '-' || coalesce(cast(issue_id as TEXT), '_dbt_utils_surrogate_key_null_') || '-' || coalesce(cast(source_relation as TEXT), '_dbt_utils_surrogate_key_null_') as TEXT)) as issue_day_id,
        earliest_open_until_date,
        cast(date_trunc('week', earliest_open_until_date) as date) as earliest_open_until_week

    from issue_spine

    where date_day <= cast( now() as date)
)

select *
from surrogate_key
