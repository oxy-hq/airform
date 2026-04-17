with  __dbt__cte__int_zendesk__ticket_resolution_times_calendar as (
with historical_solved_status as (

    select 
      *,
      row_number() over (partition by ticket_id  order by valid_starting_at asc) as row_num
    from "zendesk"."main_zendesk_intermediate"."int_zendesk__ticket_historical_status"
    where status in ('solved', 'closed') -- Ideally we are looking for solved timestamps, but Zendesk sometimes (very infrequently) closes tickets without marking them as solved

), ticket as (

    select *
    from "zendesk"."main_zendesk_source"."stg_zendesk__ticket"

), ticket_historical_assignee as (

    select *
    from "zendesk"."main_zendesk_intermediate"."int_zendesk__ticket_historical_assignee"

), ticket_historical_group as (

  select *
  from "zendesk"."main_zendesk_intermediate"."int_zendesk__ticket_historical_group"

), solved_times as (
  
  select
    source_relation,
    ticket_id,
    coalesce(min(case when status = 'solved' then valid_starting_at end), min(case when status = 'closed' then valid_starting_at end)) as first_solved_at,
    coalesce(max(case when status = 'solved' then valid_starting_at end), max(case when status = 'closed' then valid_starting_at end)) as last_solved_at,
    coalesce(sum(case when status = 'solved' then 1 else 0 end), sum(case when status = 'closed' then 1 else 0 end)) as solved_count 

  from historical_solved_status
  group by 1, 2

)

  select
    ticket.source_relation,
    ticket.ticket_id,
    ticket.created_at,
    solved_times.first_solved_at,
    solved_times.last_solved_at,
    ticket_historical_assignee.unique_assignee_count,
    ticket_historical_assignee.assignee_stations_count,
    ticket_historical_group.group_stations_count,
    ticket_historical_assignee.first_assignee_id,
    ticket_historical_assignee.last_assignee_id,
    ticket_historical_assignee.first_agent_assignment_date,
    ticket_historical_assignee.last_agent_assignment_date,
    ticket_historical_assignee.ticket_unassigned_duration_calendar_minutes,
    solved_times.solved_count as total_resolutions,
    case when solved_times.solved_count <= 1
      then 0
      else solved_times.solved_count - 1 --subtracting one as the first solve is not a reopen.
        end as count_reopens,

    date_diff('minute', ticket_historical_assignee.first_agent_assignment_date::timestamp, solved_times.last_solved_at::timestamp ) as first_assignment_to_resolution_calendar_minutes,
    date_diff('minute', ticket_historical_assignee.last_agent_assignment_date::timestamp, solved_times.last_solved_at::timestamp ) as last_assignment_to_resolution_calendar_minutes,
    date_diff('minute', ticket.created_at::timestamp, solved_times.first_solved_at::timestamp ) as first_resolution_calendar_minutes,
    date_diff('minute', ticket.created_at::timestamp, solved_times.last_solved_at::timestamp ) as final_resolution_calendar_minutes

  from ticket

  left join ticket_historical_assignee
    on ticket.ticket_id = ticket_historical_assignee.ticket_id
    and ticket.source_relation = ticket_historical_assignee.source_relation

  left join ticket_historical_group
    on ticket.ticket_id = ticket_historical_group.ticket_id
    and ticket.source_relation = ticket_historical_group.source_relation

  left join solved_times
    on ticket.ticket_id = solved_times.ticket_id
    and ticket.source_relation = solved_times.source_relation
), ticket_resolution_times_calendar as (

    select *
    from __dbt__cte__int_zendesk__ticket_resolution_times_calendar

), ticket_schedules as (

    select *
    from "zendesk"."main_zendesk_intermediate"."int_zendesk__ticket_schedules"

), schedule as (

    select *
    from "zendesk"."main_zendesk_intermediate"."int_zendesk__schedule_spine"

), ticket_resolution_times as (

    select
        ticket_resolution_times_calendar.source_relation,
        ticket_resolution_times_calendar.ticket_id,
        ticket_schedules.schedule_created_at,
        ticket_schedules.schedule_invalidated_at,
        ticket_schedules.schedule_id,

        'first' as metric_type,

        -- bringing this in the determine which schedule (Daylight Savings vs Standard time) to use
        min(ticket_resolution_times_calendar.first_solved_at) as solved_at,

        (date_diff('second', cast(-- Sunday as week start date
cast(

    date_add(date_trunc('week', 

    date_add(ticket_schedules.schedule_created_at, interval (1) day)

), interval (-1) day)

 as date)as timestamp)::timestamp, cast(ticket_schedules.schedule_created_at as timestamp)::timestamp ) /60
            ) as start_time_in_minutes_from_week,

        greatest(0,
          (
            date_diff('second', ticket_schedules.schedule_created_at::timestamp, least(ticket_schedules.schedule_invalidated_at, min(ticket_resolution_times_calendar.first_solved_at))::timestamp )/60
          )) as raw_delta_in_minutes,

        -- Sunday as week start date
cast(

    date_add(date_trunc('week', 

    date_add(ticket_schedules.schedule_created_at, interval (1) day)

), interval (-1) day)

 as date) as start_week_date

    from ticket_resolution_times_calendar
    join ticket_schedules
        on ticket_resolution_times_calendar.ticket_id = ticket_schedules.ticket_id
        and ticket_resolution_times_calendar.source_relation = ticket_schedules.source_relation
    group by 1,2,3,4,5,6

    union all

    select
        ticket_resolution_times_calendar.source_relation,
        ticket_resolution_times_calendar.ticket_id,
        ticket_schedules.schedule_created_at,
        ticket_schedules.schedule_invalidated_at,
        ticket_schedules.schedule_id,

        'full' as metric_type,

        -- bringing this in the determine which schedule (Daylight Savings vs Standard time) to use
        min(ticket_resolution_times_calendar.last_solved_at) as solved_at,

        (date_diff('second', cast(-- Sunday as week start date
cast(

    date_add(date_trunc('week', 

    date_add(ticket_schedules.schedule_created_at, interval (1) day)

), interval (-1) day)

 as date)as timestamp)::timestamp, cast(ticket_schedules.schedule_created_at as timestamp)::timestamp ) /60
            ) as start_time_in_minutes_from_week,

        greatest(0,
          (
            date_diff('second', ticket_schedules.schedule_created_at::timestamp, least(ticket_schedules.schedule_invalidated_at, min(ticket_resolution_times_calendar.last_solved_at))::timestamp )/60
          )) as raw_delta_in_minutes,

        -- Sunday as week start date
cast(

    date_add(date_trunc('week', 

    date_add(ticket_schedules.schedule_created_at, interval (1) day)

), interval (-1) day)

 as date) as start_week_date

    from ticket_resolution_times_calendar
    join ticket_schedules
        on ticket_resolution_times_calendar.ticket_id = ticket_schedules.ticket_id
        and ticket_resolution_times_calendar.source_relation = ticket_schedules.source_relation
    group by 1,2,3,4,5,6

), weeks as (

    

    

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



), weeks_cross_ticket_resolution_time as (

    -- because time is reported in minutes since the beginning of the week, we have to split up time spent on the ticket into calendar weeks
    select

        ticket_resolution_times.*,
        cast(generated_number - 1 as integer) as week_number

    from ticket_resolution_times
    cross join weeks
    where floor((start_time_in_minutes_from_week + raw_delta_in_minutes) / (7*24*60)) >= generated_number - 1

), weekly_periods as (

    select

        weeks_cross_ticket_resolution_time.*,
        greatest(0, start_time_in_minutes_from_week - week_number * (7*24*60)) as ticket_week_start_time,
        least(start_time_in_minutes_from_week + raw_delta_in_minutes - week_number * (7*24*60), (7*24*60)) as ticket_week_end_time

    from weeks_cross_ticket_resolution_time

), intercepted_periods as (

    select
        weekly_periods.source_relation,
        weekly_periods.ticket_id,
        weekly_periods.metric_type,
        weekly_periods.week_number,
        weekly_periods.schedule_id,
        weekly_periods.ticket_week_start_time,
        weekly_periods.ticket_week_end_time,
        schedule.start_time_utc as schedule_start_time,
        schedule.end_time_utc as schedule_end_time,
        least(weekly_periods.ticket_week_end_time, schedule.end_time_utc) - greatest(weekly_periods.ticket_week_start_time, schedule.start_time_utc) as scheduled_minutes
    from weekly_periods
    join schedule
        on weekly_periods.ticket_week_start_time <= schedule.end_time_utc
        and weekly_periods.ticket_week_end_time >= schedule.start_time_utc
        and weekly_periods.schedule_id = schedule.schedule_id
        and weekly_periods.source_relation = schedule.source_relation
        -- this chooses the Daylight Savings Time or Standard Time version of the schedule
        -- We have everything calculated within a week, so take us to the appropriate week first by adding the week_number * minutes-in-a-week to the minute-mark where we start and stop counting for the week
        and cast( 

    date_add(start_week_date, interval (cast(week_number * (7*24*60) + ticket_week_end_time as integer)) minute)

 as date) > cast(schedule.valid_from as date)
        and cast( 

    date_add(start_week_date, interval (cast(week_number * (7*24*60) + ticket_week_start_time as integer)) minute)

 as date) < cast(schedule.valid_until as date)

), ticket_resolution_business_minutes as (

    select
        source_relation,
        ticket_id,
        metric_type,
        sum(scheduled_minutes) as resolution_business_minutes
    from intercepted_periods
    group by 1, 2, 3

)

select
    ticket_resolution_business_minutes.source_relation,
    ticket_resolution_business_minutes.ticket_id,
    max(
        case
            when ticket_resolution_business_minutes.metric_type = 'first'
            then ticket_resolution_business_minutes.resolution_business_minutes
            else null
        end
    ) as first_resolution_business_minutes,

    max(
        case
            when ticket_resolution_business_minutes.metric_type = 'full'
            then ticket_resolution_business_minutes.resolution_business_minutes
            else null
        end
    ) as full_resolution_business_minutes

from ticket_resolution_business_minutes
group by 1, 2
