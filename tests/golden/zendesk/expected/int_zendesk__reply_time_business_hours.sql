-- step 3, determine when an SLA will breach for SLAs that are in business hours

with  __dbt__cte__int_zendesk__commenter_reply_at as (

with users as (
  select *
  from "zendesk"."main_zendesk_intermediate"."int_zendesk__user_aggregates"

), ticket_updates as (
  select *
  from "zendesk"."main_zendesk_intermediate"."int_zendesk__updates"

), final as (
  select 
    ticket_comment.source_relation,
    ticket_comment.ticket_id,
    ticket_comment.valid_starting_at as reply_at,
    commenter.role
  from ticket_updates as ticket_comment

  join users as commenter
    on ticket_comment.user_id = commenter.user_id
    and ticket_comment.source_relation = commenter.source_relation
  

  where field_name = 'comment' 
    and ticket_comment.is_public
    and commenter.is_internal_role
)

select *
from final
), ticket_schedules as (

  select *
  from "zendesk"."main_zendesk_intermediate"."int_zendesk__ticket_schedules"

), schedule as (

  select *
  from "zendesk"."main_zendesk_intermediate"."int_zendesk__schedule_spine"

), sla_policy_applied as (

  select *
  from "zendesk"."main_zendesk_intermediate"."int_zendesk__sla_policy_applied"

), reply_time as (

  select *
  from __dbt__cte__int_zendesk__commenter_reply_at

), ticket_updates as (

  select *
  from "zendesk"."main_zendesk_intermediate"."int_zendesk__updates"

), ticket_solved_times as (
  select
    source_relation,
    ticket_id,
    valid_starting_at as solved_at
  from ticket_updates
  where field_name = 'status'
  and value in ('solved','closed')

), schedule_business_hours as (

  select 
    source_relation,
    schedule_id,
    sum(end_time - start_time) as total_schedule_weekly_business_minutes
  -- referring to stg_zendesk__schedule instead of int_zendesk__schedule_spine just to calculate total minutes
  from "zendesk"."main_zendesk_source"."stg_zendesk__schedule"
  group by 1, 2

), ticket_sla_applied_with_schedules as (

  select 
    sla_policy_applied.*,
    ticket_schedules.schedule_id,
    (date_diff('second', cast(-- Sunday as week start date
cast(

    date_add(date_trunc('week', 

    date_add(sla_policy_applied.sla_applied_at, interval (1) day)

), interval (-1) day)

 as date)as timestamp)::timestamp, cast(sla_policy_applied.sla_applied_at as timestamp)::timestamp ) /60
          ) as start_time_in_minutes_from_week,
      schedule_business_hours.total_schedule_weekly_business_minutes,
    -- Sunday as week start date
cast(

    date_add(date_trunc('week', 

    date_add(sla_policy_applied.sla_applied_at, interval (1) day)

), interval (-1) day)

 as date) as start_week_date

  from sla_policy_applied
  left join ticket_schedules on sla_policy_applied.ticket_id = ticket_schedules.ticket_id
    and sla_policy_applied.source_relation = ticket_schedules.source_relation
    and 

    timestampadd(
        second,
        -1,
        ticket_schedules.schedule_created_at
        )

 <= sla_policy_applied.sla_applied_at
    and 

    timestampadd(
        second,
        -1,
        ticket_schedules.schedule_invalidated_at
        )

 > sla_policy_applied.sla_applied_at
  left join schedule_business_hours 
    on ticket_schedules.schedule_id = schedule_business_hours.schedule_id
    and ticket_schedules.source_relation = schedule_business_hours.source_relation
  where sla_policy_applied.in_business_hours
    and metric in ('next_reply_time', 'first_reply_time')

), first_reply_solve_times as (
  select
    ticket_sla_applied_with_schedules.source_relation,
    ticket_sla_applied_with_schedules.ticket_id,
    ticket_sla_applied_with_schedules.ticket_created_at,
    ticket_sla_applied_with_schedules.valid_starting_at,
    ticket_sla_applied_with_schedules.ticket_current_status,
    ticket_sla_applied_with_schedules.metric,
    ticket_sla_applied_with_schedules.latest_sla,
    ticket_sla_applied_with_schedules.sla_applied_at,
    ticket_sla_applied_with_schedules.target,
    ticket_sla_applied_with_schedules.in_business_hours,
    ticket_sla_applied_with_schedules.sla_policy_name,
    ticket_sla_applied_with_schedules.schedule_id,
    ticket_sla_applied_with_schedules.start_time_in_minutes_from_week,
    ticket_sla_applied_with_schedules.total_schedule_weekly_business_minutes,
    ticket_sla_applied_with_schedules.start_week_date,
    min(reply_time.reply_at) as first_reply_time,
    min(ticket_solved_times.solved_at) as first_solved_time
  from ticket_sla_applied_with_schedules
  left join reply_time
    on reply_time.ticket_id = ticket_sla_applied_with_schedules.ticket_id
    and reply_time.reply_at > ticket_sla_applied_with_schedules.sla_applied_at
    and reply_time.source_relation = ticket_sla_applied_with_schedules.source_relation
  left join ticket_solved_times
    on ticket_sla_applied_with_schedules.ticket_id = ticket_solved_times.ticket_id
    and ticket_solved_times.solved_at > ticket_sla_applied_with_schedules.sla_applied_at
    and ticket_solved_times.source_relation = ticket_sla_applied_with_schedules.source_relation
  group by 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15

), week_index_calc as (
    select 
        *,
        date_diff('week', sla_applied_at::timestamp, least(coalesce(first_reply_time, now()), coalesce(first_solved_time, now()))::timestamp ) + 1 as week_index
    from first_reply_solve_times

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



), weeks_cross_ticket_sla_applied as (
    -- because time is reported in minutes since the beginning of the week, we have to split up time spent on the ticket into calendar weeks
    select
      week_index_calc.*,
      cast(weeks.generated_number - 1 as integer) as week_number

    from week_index_calc
    cross join weeks
    where week_index >= generated_number - 1

), weekly_periods as (
  
  select 
    weeks_cross_ticket_sla_applied.*,
    greatest(0, start_time_in_minutes_from_week - week_number * (7*24*60)) as ticket_week_start_time,
    (7*24*60) as ticket_week_end_time
  from weeks_cross_ticket_sla_applied

), intercepted_periods as (

  select 
    weekly_periods.*,
    schedule.start_time_utc as schedule_start_time,
    schedule.end_time_utc as schedule_end_time,
    (schedule.end_time_utc - greatest(ticket_week_start_time,schedule.start_time_utc)) as lapsed_business_minutes,
    sum(schedule.end_time_utc - greatest(ticket_week_start_time,schedule.start_time_utc)) over 
      (partition by ticket_id, sla_policy_name, metric, sla_applied_at  
        order by week_number, schedule.start_time_utc
        rows between unbounded preceding and current row) as sum_lapsed_business_minutes
  from weekly_periods
  join schedule on ticket_week_start_time <= schedule.end_time_utc 
    and ticket_week_end_time >= schedule.start_time_utc
    and weekly_periods.schedule_id = schedule.schedule_id
    and weekly_periods.source_relation = schedule.source_relation
    -- this chooses the Daylight Savings Time or Standard Time version of the schedule
    -- We have everything calculated within a week, so take us to the appropriate week first by adding the week_number * minutes-in-a-week to the minute-mark where we start and stop counting for the week
    and cast (

    date_add(start_week_date, interval (cast(week_number * (7*24*60) + ticket_week_end_time as integer)) minute)

 as date) > cast(schedule.valid_from as date)
    and cast (

    date_add(start_week_date, interval (cast(week_number * (7*24*60) + ticket_week_start_time as integer)) minute)

 as date) < cast(schedule.valid_until as date)

), intercepted_periods_with_breach_flag as (
  
  select 
    *,
    target - sum_lapsed_business_minutes as remaining_minutes,
    case when (target - sum_lapsed_business_minutes) < 0 
      and 
        (lag(target - sum_lapsed_business_minutes) over
        (partition by ticket_id, sla_policy_name, metric, sla_applied_at  order by week_number, schedule_start_time) >= 0 
        or 
        lag(target - sum_lapsed_business_minutes) over
        (partition by ticket_id, sla_policy_name, metric, sla_applied_at  order by week_number, schedule_start_time) is null) 
        then true else false end as is_breached_during_schedule -- this flags the scheduled period on which the breach took place
  from intercepted_periods

), intercepted_periods_with_breach_flag_calculated as (

  select
    *,
    schedule_end_time + remaining_minutes as breached_at_minutes,
    -- Sunday as week start date
cast(

    date_add(date_trunc('week', 

    date_add(sla_applied_at, interval (1) day)

), interval (-1) day)

 as date) as starting_point,
    

    timestampadd(
        second,
        cast(((7*24*60*60) * week_number) + ((schedule_end_time + remaining_minutes) * 60) as integer ),
        cast(-- Sunday as week start date
cast(

    date_add(date_trunc('week', 

    date_add(sla_applied_at, interval (1) day)

), interval (-1) day)

 as date) as timestamp)
        )

 as sla_breach_at,
    

    timestampadd(
        second,
        cast(((7*24*60*60) * week_number) + (schedule_start_time * 60) as integer ),
        cast(-- Sunday as week start date
cast(

    date_add(date_trunc('week', 

    date_add(sla_applied_at, interval (1) day)

), interval (-1) day)

 as date) as timestamp)
        )

 as sla_schedule_start_at,
    

    timestampadd(
        second,
        cast(((7*24*60*60) * week_number) + (schedule_end_time * 60) as integer ),
        cast(-- Sunday as week start date
cast(

    date_add(date_trunc('week', 

    date_add(sla_applied_at, interval (1) day)

), interval (-1) day)

 as date) as timestamp)
        )

 as sla_schedule_end_at,
    cast(

    date_add(-- Sunday as week start date
cast(

    date_add(date_trunc('week', 

    date_add(sla_applied_at, interval (1) day)

), interval (-1) day)

 as date), interval (6) day)

 as date) as week_end_date
  from intercepted_periods_with_breach_flag

), reply_time_business_hours_sla as (

  select
    source_relation,
    ticket_id,
    sla_policy_name,
    metric,
    ticket_created_at,
    sla_applied_at,
    greatest(sla_applied_at,sla_schedule_start_at) as sla_schedule_start_at,
    sla_schedule_end_at,
    target,
    sum_lapsed_business_minutes,
    in_business_hours,
    sla_breach_at,
    is_breached_during_schedule,
    total_schedule_weekly_business_minutes,
    max(case when is_breached_during_schedule then sla_breach_at else null end) over (partition by ticket_id, sla_policy_name, metric, sla_applied_at, target ) as sla_breach_exact_time,
    week_number
  from intercepted_periods_with_breach_flag_calculated

) 

select * 
from reply_time_business_hours_sla
