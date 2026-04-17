--final step where we union together all of the reply time, agent work time, and requester wait time sla's

with reply_time_sla as (

  select * 
  from "zendesk"."main_zendesk_intermediate"."int_zendesk__reply_time_combined"

), agent_work_calendar_sla as (

  select *
  from "zendesk"."main_zendesk_intermediate"."int_zendesk__agent_work_time_calendar_hours"

), requester_wait_calendar_sla as (

  select *
  from "zendesk"."main_zendesk_intermediate"."int_zendesk__requester_wait_time_calendar_hours"



), agent_work_business_sla as (

  select *
  from "zendesk"."main_zendesk_intermediate"."int_zendesk__agent_work_time_business_hours"

), requester_wait_business_sla as (
  select *
  from "zendesk"."main_zendesk_intermediate"."int_zendesk__requester_wait_time_business_hours"



), all_slas_unioned as (
  select
    source_relation,
    ticket_id,
    sla_policy_name,
    metric,
    sla_applied_at,
    target,
    in_business_hours,
    sla_update_at as sla_breach_at,
    sla_elapsed_time,
    is_sla_breached
  from reply_time_sla

union all

  select
    source_relation,
    ticket_id,
    sla_policy_name,
    'agent_work_time' as metric,
    sla_applied_at,
    target,
    false as in_business_hours,
    max(sla_breach_at) as sla_breach_at,
    max(running_total_calendar_minutes) as sla_elapsed_time,
    

    bool_or( is_breached_during_schedule )

 as is_sla_breached
  from agent_work_calendar_sla

  group by 1,2,3,4,5,6,7

union all

  select
    source_relation,
    ticket_id,
    sla_policy_name,
    'requester_wait_time' as metric,
    sla_applied_at,
    target,
    false as in_business_hours,
    max(sla_breach_at) as sla_breach_at,
    max(running_total_calendar_minutes) as sla_elapsed_time,
    

    bool_or( is_breached_during_schedule )

 as is_sla_breached
  from requester_wait_calendar_sla

  group by 1,2,3,4,5,6,7




union all 

  select 
    source_relation,
    ticket_id,
    sla_policy_name,
    'agent_work_time' as metric,
    sla_applied_at,
    target,
    true as in_business_hours,
    max(sla_breach_at) as sla_breach_at,
    max(running_total_scheduled_minutes) as sla_elapsed_time,
    

    bool_or( is_breached_during_schedule )

 as is_sla_breached
  from agent_work_business_sla
  
  group by 1,2,3,4,5,6,7

union all 

  select 
    source_relation,
    ticket_id,
    sla_policy_name,
    'requester_wait_time' as metric,
    sla_applied_at,
    target,
    true as in_business_hours,
    max(sla_breach_at) as sla_breach_at,
    max(running_total_scheduled_minutes) as sla_elapsed_time,
    

    bool_or( is_breached_during_schedule )

 as is_sla_breached
    
  from requester_wait_business_sla
  
  group by 1,2,3,4,5,6,7



)

select 
  md5(cast(coalesce(cast(source_relation as TEXT), '_dbt_utils_surrogate_key_null_') || '-' || coalesce(cast(ticket_id as TEXT), '_dbt_utils_surrogate_key_null_') || '-' || coalesce(cast(metric as TEXT), '_dbt_utils_surrogate_key_null_') || '-' || coalesce(cast(sla_applied_at as TEXT), '_dbt_utils_surrogate_key_null_') as TEXT)) as sla_event_id,
  source_relation,
  ticket_id,
  sla_policy_name,
  metric,
  sla_applied_at,
  target,
  in_business_hours,
  sla_breach_at,
  case when sla_elapsed_time is null
    then round(cast((date_diff('second', sla_applied_at::timestamp, now()::timestamp ) / 60) as numeric(28,6)), 4)  --This will create an entry for active sla's
    else round(cast(sla_elapsed_time as numeric(28,6)), 4)
      end as sla_elapsed_time,
  sla_breach_at > current_timestamp as is_active_sla,
  case when (sla_breach_at > now())
    then null
    else is_sla_breached
      end as is_sla_breach
from all_slas_unioned
