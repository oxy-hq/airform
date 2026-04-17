-- Calculate breach time for requester wait time, calendar hours
with requester_wait_time_filtered_statuses as (

  select *
  from "zendesk"."main_zendesk_intermediate"."int_zendesk__requester_wait_time_filtered_statuses"
  where not in_business_hours

), requester_wait_time_calendar_minutes as (

  select 
    *,
    date_diff('minute', valid_starting_at::timestamp, valid_ending_at::timestamp ) as calendar_minutes,
    sum(date_diff('minute', valid_starting_at::timestamp, valid_ending_at::timestamp ) ) 
      over (partition by ticket_id, sla_applied_at  order by valid_starting_at rows between unbounded preceding and current row) as running_total_calendar_minutes
  from requester_wait_time_filtered_statuses

), requester_wait_time_calendar_minutes_flagged as (

select 
  requester_wait_time_calendar_minutes.*,
  target - running_total_calendar_minutes as remaining_target_minutes,
  case when (target - running_total_calendar_minutes) < 0 
      and 
        (lag(target - running_total_calendar_minutes) over
        (partition by ticket_id, sla_applied_at  order by valid_starting_at) >= 0 
        or 
        lag(target - running_total_calendar_minutes) over
        (partition by ticket_id, sla_applied_at  order by valid_starting_at) is null) 
        then true else false end as is_breached_during_schedule
        
from  requester_wait_time_calendar_minutes

), final as (
  select
    *,
    (remaining_target_minutes + calendar_minutes) as breach_minutes,
    

    timestampadd(
        second,
        cast(((remaining_target_minutes + calendar_minutes) * 60) as integer ),
        valid_starting_at
        )

 as sla_breach_at
  from requester_wait_time_calendar_minutes_flagged

)

select *
from final
