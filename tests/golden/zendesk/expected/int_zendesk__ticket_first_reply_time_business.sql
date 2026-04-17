with  __dbt__cte__int_zendesk__comments_enriched as (


with ticket_comment as (

    select *
    from "zendesk"."main_zendesk_intermediate"."int_zendesk__updates"
    where field_name = 'comment'

), users as (

    select *
    from "zendesk"."main_zendesk_intermediate"."int_zendesk__user_aggregates"

), joined as (

    select 

        ticket_comment.*,
        case when commenter.role in ('not set', 'end-user') then 'external_comment'
            when commenter.is_internal_role then 'internal_comment'
            else 'unknown'
            end as commenter_role
    
    from ticket_comment
    join users as commenter
        on commenter.user_id = ticket_comment.user_id
        and commenter.source_relation = ticket_comment.source_relation

    

), add_previous_commenter_role as (
    /*
    In int_zendesk__ticket_reply_times we will only be focusing on reply times between public tickets.
    The below union explicitly identifies the previous commenter roles of public and not public comments.
    */
    select
        *,
        coalesce(
            lag(commenter_role) over (partition by ticket_id  order by valid_starting_at, commenter_role)
            , 'first_comment') 
            as previous_commenter_role
    from joined
    where is_public

    union all

    select
        *,
        'non_public_comment' as previous_commenter_role
    from joined
    where not is_public
)

select 
    *,
    first_value(valid_starting_at) over (partition by ticket_id  order by valid_starting_at desc, ticket_id rows unbounded preceding) as last_comment_added_at,
    sum(case when not is_public then 1 else 0 end) over (partition by ticket_id  order by valid_starting_at rows between unbounded preceding and current row) as previous_internal_comment_count
from add_previous_commenter_role
),  __dbt__cte__int_zendesk__ticket_reply_times as (
with ticket_public_comments as (

    select *
    from __dbt__cte__int_zendesk__comments_enriched
    where is_public

), end_user_comments as (
  
  select
    source_relation,
    ticket_id,
    valid_starting_at as end_user_comment_created_at,
    ticket_created_date,
    commenter_role,
    previous_internal_comment_count,
    previous_commenter_role = 'first_comment' as is_first_comment
  from ticket_public_comments 
  where (commenter_role = 'external_comment'
    and ticket_public_comments.previous_commenter_role != 'external_comment') -- we only care about net new end user comments
    or previous_commenter_role = 'first_comment' -- We also want to take into consideration internal first comment replies

), reply_timestamps as (  

  select
    end_user_comments.source_relation,
    end_user_comments.ticket_id,
    -- If the commentor was internal, a first comment, and had previous non public internal comments then we want the ticket created date to be the end user comment created date
    -- Otherwise we will want to end user comment created date
    case when is_first_comment then end_user_comments.ticket_created_date else end_user_comments.end_user_comment_created_at end as end_user_comment_created_at,
    end_user_comments.is_first_comment,
    min(case when is_first_comment 
        and end_user_comments.commenter_role != 'external_comment' 
        and (end_user_comments.previous_internal_comment_count > 0)
          then end_user_comments.end_user_comment_created_at 
        else agent_comments.valid_starting_at end) as agent_responded_at
  from end_user_comments
  left join ticket_public_comments as agent_comments
    on agent_comments.ticket_id = end_user_comments.ticket_id
    and agent_comments.commenter_role = 'internal_comment'
    and agent_comments.valid_starting_at > end_user_comments.end_user_comment_created_at
    and end_user_comments.source_relation = agent_comments.source_relation
  group by 1,2,3,4

)

  select
    *,
    (date_diff('second', end_user_comment_created_at::timestamp, agent_responded_at::timestamp ) / 60) as reply_time_calendar_minutes
  from reply_timestamps
  order by 1,2
), ticket_reply_times as (

    select *
    from __dbt__cte__int_zendesk__ticket_reply_times

), ticket_schedules as (

    select 
      *
    from "zendesk"."main_zendesk_intermediate"."int_zendesk__ticket_schedules"

), schedule as (

    select *
    from "zendesk"."main_zendesk_intermediate"."int_zendesk__schedule_spine"

), first_reply_time as (

    select
      source_relation,
      ticket_id,
      end_user_comment_created_at,
      agent_responded_at

    from ticket_reply_times
    where is_first_comment

), ticket_first_reply_time as (

  select 
    first_reply_time.source_relation,
    first_reply_time.ticket_id,
    ticket_schedules.schedule_created_at,
    ticket_schedules.schedule_invalidated_at,
    ticket_schedules.schedule_id,

    -- bringing this in the determine which schedule (Daylight Savings vs Standard time) to use
    min(first_reply_time.agent_responded_at) as agent_responded_at,

    (date_diff('second', cast(-- Sunday as week start date
cast(

    date_add(date_trunc('week', 

    date_add(ticket_schedules.schedule_created_at, interval (1) day)

), interval (-1) day)

 as date)as timestamp)::timestamp, cast(ticket_schedules.schedule_created_at as timestamp)::timestamp ) /60
          ) as start_time_in_minutes_from_week,
    greatest(0,
      (
        date_diff('second', ticket_schedules.schedule_created_at::timestamp, least(ticket_schedules.schedule_invalidated_at, min(first_reply_time.agent_responded_at))::timestamp )/60
        )) as raw_delta_in_minutes,
    -- Sunday as week start date
cast(

    date_add(date_trunc('week', 

    date_add(ticket_schedules.schedule_created_at, interval (1) day)

), interval (-1) day)

 as date) as start_week_date
  
  from first_reply_time
  join ticket_schedules 
    on first_reply_time.ticket_id = ticket_schedules.ticket_id
    and first_reply_time.source_relation = ticket_schedules.source_relation
  group by 1,2,3,4,5

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



), weeks_cross_ticket_first_reply as (
    -- because time is reported in minutes since the beginning of the week, we have to split up time spent on the ticket into calendar weeks
    select 

      ticket_first_reply_time.*,
      cast(generated_number - 1 as integer) as week_number

    from ticket_first_reply_time
    cross join weeks
    where floor((start_time_in_minutes_from_week + raw_delta_in_minutes) / (7*24*60)) >= generated_number - 1

), weekly_periods as (
  
    select 
      weeks_cross_ticket_first_reply.*, 
      -- for each week, at what minute do we start counting?
      greatest(0, start_time_in_minutes_from_week - week_number * (7*24*60)) as ticket_week_start_time,
      -- for each week, at what minute do we stop counting?
      least(start_time_in_minutes_from_week + raw_delta_in_minutes - week_number * (7*24*60), (7*24*60)) as ticket_week_end_time
    from weeks_cross_ticket_first_reply

), intercepted_periods as (

  select 
      weekly_periods.source_relation,
      ticket_id,
      week_number,
      weekly_periods.schedule_id,
      ticket_week_start_time,
      ticket_week_end_time,
      schedule.start_time_utc as schedule_start_time,
      schedule.end_time_utc as schedule_end_time,
      least(ticket_week_end_time, schedule.end_time_utc) - greatest(ticket_week_start_time, schedule.start_time_utc) as scheduled_minutes
  from weekly_periods
  join schedule on ticket_week_start_time <= schedule.end_time_utc 
    and ticket_week_end_time >= schedule.start_time_utc
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
      
)

  select 
    ticket_id, 
    source_relation,
    sum(scheduled_minutes) as first_reply_time_business_minutes
  from intercepted_periods
  group by 1, 2
