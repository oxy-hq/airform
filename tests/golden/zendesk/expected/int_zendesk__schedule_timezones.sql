with  __dbt__cte__int_zendesk__timezone_daylight as (


with timezone as (

    select *
    from "zendesk"."main_zendesk_source"."stg_zendesk__time_zone"

), daylight_time as (

    select *
    from "zendesk"."main_zendesk_source"."stg_zendesk__daylight_time"

), timezone_with_dt as (

    select 
        timezone.*,
        daylight_time.daylight_start_utc,
        daylight_time.daylight_end_utc,
        daylight_time.daylight_offset_minutes

    from timezone 
    left join daylight_time 
        on timezone.time_zone = daylight_time.time_zone
        and timezone.source_relation = daylight_time.source_relation

), order_timezone_dt as (

    select 
        *,
        -- will be null for timezones without any daylight savings records (and the first entry)
        -- we will coalesce the first entry date with .... the X years ago
        lag(daylight_end_utc, 1) over (partition by time_zone  order by daylight_end_utc asc) as last_daylight_end_utc,
        -- will be null for timezones without any daylight savings records (and the last entry)
        -- we will coalesce the last entry date with the current date 
        lead(daylight_start_utc, 1) over (partition by time_zone  order by daylight_start_utc asc) as next_daylight_start_utc

    from timezone_with_dt

), split_timezones as (

    -- standard (includes timezones without DT)
    -- starts: when the last Daylight Savings ended
    -- ends: when the next Daylight Savings starts
    select 
        source_relation,
        time_zone,
        standard_offset_minutes as offset_minutes,

        -- last_daylight_end_utc is null for the first record of the time_zone's daylight time, or if the TZ doesn't use DT
        coalesce(last_daylight_end_utc, cast('1970-01-01' as date)) as valid_from,

        -- daylight_start_utc is null for timezones that don't use DT
        coalesce(daylight_start_utc, cast( 

    date_add(now(), interval (1) year)

 as date)) as valid_until

    from order_timezone_dt

    union all 

    -- DT (excludes timezones without it)
    -- starts: when this Daylight Savings started
    -- ends: when this Daylight Savings ends
    select 
        source_relation,
        time_zone,
        -- Pacific Time is -8h during standard time and -7h during DT
        standard_offset_minutes + daylight_offset_minutes as offset_minutes,
        daylight_start_utc as valid_from,
        daylight_end_utc as valid_until

    from order_timezone_dt
    where daylight_offset_minutes is not null

    union all

    select
        source_relation,
        time_zone,
        standard_offset_minutes as offset_minutes,

        -- Get the latest daylight_end_utc time and set that as the valid_from
        max(daylight_end_utc) as valid_from,

        -- If the latest_daylight_end_time_utc is less than todays timestamp, that means DST has ended. Therefore, we will make the valid_until in the future.
        cast( 

    date_add(now(), interval (1) year)

 as date) as valid_until

    from order_timezone_dt
    group by 1, 2, 3
    -- We only want to apply this logic to time_zone's that had daylight saving time and it ended at a point. For example, Hong Kong ended DST in 1979.
    having cast(max(daylight_end_utc) as date) < cast(now() as date)

), final as (
    select
        source_relation,
        lower(time_zone) as time_zone,
        offset_minutes,
        cast(valid_from as timestamp) as valid_from,
        cast(valid_until as timestamp) as valid_until
    from split_timezones
)

select * 
from final
), split_timezones as (
    select *
    from __dbt__cte__int_zendesk__timezone_daylight  

), schedule as (
    select 
        *,
        max(created_at) over (partition by schedule_id ) as max_created_at
    from "zendesk"."main_zendesk_source"."stg_zendesk__schedule"   

 -- when not using schedule histories
), final_schedule as (
    select 
        schedule.source_relation,
        schedule.schedule_id,
        0 as schedule_id_index,
        lower(schedule.time_zone) as time_zone,
        schedule.schedule_name,
        coalesce(split_timezones.offset_minutes, 0) as offset_minutes,
        schedule.start_time - coalesce(split_timezones.offset_minutes, 0) as start_time_utc,
        schedule.end_time - coalesce(split_timezones.offset_minutes, 0) as end_time_utc,
        cast(date_trunc('day', split_timezones.valid_from) as timestamp) as schedule_valid_from,
        cast(date_trunc('day', split_timezones.valid_until)  as timestamp) as schedule_valid_until,
        cast(date_trunc('day', split_timezones.valid_from) as timestamp) as timezone_valid_from,
        cast(date_trunc('day', split_timezones.valid_until)  as timestamp) as timezone_valid_until
    from schedule
    left join split_timezones
        on split_timezones.time_zone = lower(schedule.time_zone)
        and schedule.source_relation = split_timezones.source_relation


), final as (
    select
        source_relation,
        schedule_id,
        schedule_id_index,
        time_zone,
        schedule_name,
        offset_minutes,
        start_time_utc,
        end_time_utc,
        schedule_valid_from,
        schedule_valid_until,
        -- use zendesk.fivetran_week_start to ensure we truncate to Sunday
        cast(-- Sunday as week start date
cast(

    date_add(date_trunc('week', 

    date_add(schedule_valid_from, interval (1) day)

), interval (-1) day)

 as date) as timestamp) as schedule_starting_sunday,
        cast(-- Sunday as week start date
cast(

    date_add(date_trunc('week', 

    date_add(schedule_valid_until, interval (1) day)

), interval (-1) day)

 as date) as timestamp) as schedule_ending_sunday,
        -- Check if the start fo the schedule was from a schedule or timezone change for tracking downstream.
        case when schedule_valid_from = timezone_valid_from
            then 'timezone'
            else 'schedule'
            end as change_type
    from final_schedule
)

select * 
from final
