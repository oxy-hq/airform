with schedule as (
    select *
    from "zendesk"."main_zendesk_source"."stg_zendesk__schedule"   

), schedule_holiday as (
    select *
    from "zendesk"."main_zendesk_source"."stg_zendesk__schedule_holiday"  

-- Converts holiday_start_date_at and holiday_end_date_at into daily timestamps and finds the week starts/ends using week_start.
), schedule_holiday_ranges as (
    select
        source_relation,
        holiday_name,
        schedule_id,
        cast(date_trunc('day', holiday_start_date_at) as timestamp) as holiday_valid_from,
        cast(date_trunc('day', holiday_end_date_at)  as timestamp) as holiday_valid_until,
        cast(-- Sunday as week start date
cast(

    date_add(date_trunc('week', 

    date_add(holiday_start_date_at, interval (1) day)

), interval (-1) day)

 as date) as timestamp) as holiday_starting_sunday,
        cast(-- Sunday as week start date
cast(

    date_add(date_trunc('week', 

    date_add(

    date_add(holiday_end_date_at, interval (1) week)

, interval (1) day)

), interval (-1) day)

 as date) as timestamp) as holiday_ending_sunday,
        -- Since the spine is based on weeks, holidays that span multiple weeks need to be broken up in to weeks. First step is to find those holidays.
        date_diff('week', holiday_start_date_at::timestamp, holiday_end_date_at::timestamp ) + 1 as holiday_weeks_spanned
    from schedule_holiday

-- Creates a record for each week of multi-week holidays. Update valid_from and valid_until in the next cte.
), expanded_holidays as (
    select
        schedule_holiday_ranges.*,
        cast(week_numbers.generated_number as integer) as holiday_week_number
    from schedule_holiday_ranges
    -- Generate a sequence of numbers from 0 to the max number of weeks spanned, assuming a holiday won't span more than max_ticket_length_weeks (default=52) weeks
    cross join (

    

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
    where generated_number <= 52
    order by generated_number

) as week_numbers
    where schedule_holiday_ranges.holiday_weeks_spanned > 1
    and week_numbers.generated_number <= schedule_holiday_ranges.holiday_weeks_spanned

-- Define start and end times for each segment of a multi-week holiday.
), split_multiweek_holidays as (

    -- Business as usual for holidays that fall within a single week.
    select
        source_relation,
        holiday_name,
        schedule_id,
        holiday_valid_from,
        holiday_valid_until,
        holiday_starting_sunday,
        holiday_ending_sunday,
        holiday_weeks_spanned
    from schedule_holiday_ranges
    where holiday_weeks_spanned = 1

    union all

    -- Split holidays by week that span multiple weeks since the schedule spine is based on weeks.
    select
        source_relation,
        holiday_name,
        schedule_id,
        case 
            when holiday_week_number = 1 -- first week in multiweek holiday
            then holiday_valid_from
            -- We have to use days in case warehouse does not truncate to Sunday.
            else cast(

    date_add(holiday_starting_sunday, interval ((holiday_week_number - 1) * 7) day)

 as timestamp)
        end as holiday_valid_from,
        case 
            when holiday_week_number = holiday_weeks_spanned -- last week in multiweek holiday
            then holiday_valid_until
            -- We have to use days in case warehouse does not truncate to Sunday.
            else cast(

    date_add(

    date_add(holiday_starting_sunday, interval (holiday_week_number * 7) day)

, interval (-1) day)

 as timestamp) -- saturday
        end as holiday_valid_until,
        case 
            when holiday_week_number = 1 -- first week in multiweek holiday
            then holiday_starting_sunday
            -- We have to use days in case warehouse does not truncate to Sunday.
            else cast(

    date_add(holiday_starting_sunday, interval ((holiday_week_number - 1) * 7) day)

 as timestamp)
        end as holiday_starting_sunday,
        case 
            when holiday_week_number = holiday_weeks_spanned -- last week in multiweek holiday
            then holiday_ending_sunday
            -- We have to use days in case warehouse does not truncate to Sunday.
            else cast(

    date_add(holiday_starting_sunday, interval (holiday_week_number * 7) day)

 as timestamp)
        end as holiday_ending_sunday,
        holiday_weeks_spanned
    from expanded_holidays
    where holiday_weeks_spanned > 1

-- Create a record for each the holiday start and holiday end for each week to use downstream.
), split_holidays as (
    -- Creates a record that will be used for the time before a holiday
    select
        split_multiweek_holidays.*,
        holiday_valid_from as holiday_date,
        '0_gap' as holiday_start_or_end
    from split_multiweek_holidays

    union all

    -- Creates another record that will be used for the holiday itself
    select
        split_multiweek_holidays.*,
        holiday_valid_until as holiday_date,
        '1_holiday' as holiday_start_or_end
    from split_multiweek_holidays
)

select *
from split_holidays
