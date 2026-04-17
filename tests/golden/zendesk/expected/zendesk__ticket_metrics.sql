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
),  __dbt__cte__int_zendesk__comments_enriched as (


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
),  __dbt__cte__int_zendesk__ticket_reply_times_calendar as (
with ticket as (

  select *
  from "zendesk"."main_zendesk_source"."stg_zendesk__ticket"

), ticket_reply_times as (

  select *
  from __dbt__cte__int_zendesk__ticket_reply_times

)

select
  ticket.source_relation,
  ticket.ticket_id,
  sum(case when is_first_comment then reply_time_calendar_minutes
    else null end) as first_reply_time_calendar_minutes,
  sum(reply_time_calendar_minutes) as total_reply_time_calendar_minutes --total combined time the customer waits for internal response
  
from ticket
left join ticket_reply_times
  on ticket.ticket_id = ticket_reply_times.ticket_id
  and ticket.source_relation = ticket_reply_times.source_relation

group by 1, 2
),  __dbt__cte__int_zendesk__ticket_work_time_calendar as (
with ticket_historical_status as (

    select *
    from "zendesk"."main_zendesk_intermediate"."int_zendesk__ticket_historical_status"

), calendar_minutes as (
  
    select 
        source_relation,
        ticket_id,
        status,
        case when status in ('pending') then status_duration_calendar_minutes
            else 0 end as agent_wait_time_in_minutes,
        case when status in ('new', 'open', 'hold') then status_duration_calendar_minutes
            else 0 end as requester_wait_time_in_minutes,
        case when status in ('new', 'open', 'hold', 'pending') then status_duration_calendar_minutes 
            else 0 end as solve_time_in_minutes, 
        case when status in ('new', 'open') then status_duration_calendar_minutes
            else 0 end as agent_work_time_in_minutes,
        case when status in ('hold') then status_duration_calendar_minutes
            else 0 end as on_hold_time_in_minutes,
        case when status = 'new' then status_duration_calendar_minutes
            else 0 end as new_status_duration_minutes,
        case when status = 'open' then status_duration_calendar_minutes
            else 0 end as open_status_duration_minutes,
        case when status = 'deleted' then 1
            else 0 end as ticket_deleted,
        first_value(valid_starting_at) over (partition by ticket_id  order by valid_starting_at desc, ticket_id, source_relation rows unbounded preceding) as last_status_assignment_date,
        case when lag(status) over (partition by ticket_id  order by valid_starting_at) = 'deleted' and status != 'deleted'
            then 1
            else 0
                end as ticket_recoveries

    from ticket_historical_status

)

select 
  source_relation,
  ticket_id,
  last_status_assignment_date,
  sum(ticket_deleted) as ticket_deleted_count,
  sum(agent_wait_time_in_minutes) as agent_wait_time_in_calendar_minutes,
  sum(requester_wait_time_in_minutes) as requester_wait_time_in_calendar_minutes,
  sum(solve_time_in_minutes) as solve_time_in_calendar_minutes,
  sum(agent_work_time_in_minutes) as agent_work_time_in_calendar_minutes,
  sum(on_hold_time_in_minutes) as on_hold_time_in_calendar_minutes,
  sum(new_status_duration_minutes) as new_status_duration_in_calendar_minutes,
  sum(open_status_duration_minutes) as open_status_duration_in_calendar_minutes,
  sum(ticket_recoveries) as total_ticket_recoveries
from calendar_minutes
group by 1, 2, 3
), ticket_enriched as (

  select *
  from "zendesk"."main_zendesk"."zendesk__ticket_enriched"

), ticket_resolution_times_calendar as (

  select *
  from __dbt__cte__int_zendesk__ticket_resolution_times_calendar

), ticket_reply_times_calendar as (

  select *
  from __dbt__cte__int_zendesk__ticket_reply_times_calendar

), ticket_comments as (

  select *
  from "zendesk"."main_zendesk_intermediate"."int_zendesk__comment_metrics"

), ticket_work_time_calendar as (

  select *
  from __dbt__cte__int_zendesk__ticket_work_time_calendar

-- business hour CTEs


), ticket_resolution_time_business as (

  select *
  from "zendesk"."main_zendesk"."int_zendesk__ticket_resolution_time_business_combined"

), ticket_work_time_business as (

  select *
  from "zendesk"."main_zendesk"."int_zendesk__ticket_work_time_business"

), ticket_first_reply_time_business as (

  select *
  from "zendesk"."main_zendesk"."int_zendesk__ticket_first_reply_time_business"


-- end business hour CTEs

), calendar_hour_metrics as (

select
  ticket_enriched.*,
  case when coalesce(ticket_comments.count_public_agent_comments, 0) = 0
    then null
    else round(cast(ticket_reply_times_calendar.first_reply_time_calendar_minutes as numeric(28,6)), 4)
      end as first_reply_time_calendar_minutes,
  case when coalesce(ticket_comments.count_public_agent_comments, 0) = 0
    then null
    else round(cast(ticket_reply_times_calendar.total_reply_time_calendar_minutes as numeric(28,6)), 4)
      end as total_reply_time_calendar_minutes,
  coalesce(ticket_comments.count_agent_comments, 0) as count_agent_comments,
  coalesce(ticket_comments.count_public_agent_comments, 0) as count_public_agent_comments,
  coalesce(ticket_comments.count_end_user_comments, 0) as count_end_user_comments,
  coalesce(ticket_comments.count_public_comments, 0) as count_public_comments,
  coalesce(ticket_comments.count_internal_comments, 0) as count_internal_comments,
  coalesce(ticket_comments.total_comments, 0) as total_comments,
  coalesce(ticket_comments.count_ticket_handoffs, 0) as count_ticket_handoffs, -- the number of distinct internal users who commented on the ticket
  ticket_comments.last_comment_added_at as ticket_last_comment_date,
  ticket_resolution_times_calendar.unique_assignee_count,
  ticket_resolution_times_calendar.assignee_stations_count,
  ticket_resolution_times_calendar.group_stations_count,
  ticket_resolution_times_calendar.first_assignee_id,
  ticket_resolution_times_calendar.last_assignee_id,
  ticket_resolution_times_calendar.first_agent_assignment_date,
  ticket_resolution_times_calendar.last_agent_assignment_date,
  ticket_resolution_times_calendar.first_solved_at,
  ticket_resolution_times_calendar.last_solved_at,
  case when ticket_enriched.status in ('solved', 'closed')
    then ticket_resolution_times_calendar.first_assignment_to_resolution_calendar_minutes
    else null
      end as first_assignment_to_resolution_calendar_minutes,
  case when ticket_enriched.status in ('solved', 'closed')
    then ticket_resolution_times_calendar.last_assignment_to_resolution_calendar_minutes
    else null
      end as last_assignment_to_resolution_calendar_minutes,
  round(cast(ticket_resolution_times_calendar.ticket_unassigned_duration_calendar_minutes as numeric(28,6)), 4) as ticket_unassigned_duration_calendar_minutes,
  ticket_resolution_times_calendar.first_resolution_calendar_minutes,
  ticket_resolution_times_calendar.final_resolution_calendar_minutes,
  ticket_resolution_times_calendar.total_resolutions as count_resolutions,
  ticket_resolution_times_calendar.count_reopens,
  ticket_work_time_calendar.ticket_deleted_count,
  ticket_work_time_calendar.total_ticket_recoveries,
  ticket_work_time_calendar.last_status_assignment_date,
  ticket_work_time_calendar.new_status_duration_in_calendar_minutes,
  ticket_work_time_calendar.open_status_duration_in_calendar_minutes,
  ticket_work_time_calendar.agent_wait_time_in_calendar_minutes,
  ticket_work_time_calendar.requester_wait_time_in_calendar_minutes,
  ticket_work_time_calendar.solve_time_in_calendar_minutes,
  ticket_work_time_calendar.agent_work_time_in_calendar_minutes,
  ticket_work_time_calendar.on_hold_time_in_calendar_minutes,
  coalesce(ticket_comments.count_agent_replies, 0) as total_agent_replies,
  
  case when ticket_enriched.is_requester_active = true and ticket_enriched.requester_last_login_at is not null
    then round(cast((date_diff('second', ticket_enriched.requester_last_login_at::timestamp, now()::timestamp ) /60) as numeric(28,6)), 4)
      end as requester_last_login_age_minutes,
  case when ticket_enriched.is_assignee_active = true and ticket_enriched.assignee_last_login_at is not null
    then round(cast((date_diff('second', ticket_enriched.assignee_last_login_at::timestamp, now()::timestamp ) /60) as numeric(28,6)), 4)
      end as assignee_last_login_age_minutes,
  case when lower(ticket_enriched.status) not in ('solved','closed')
    then round(cast((date_diff('second', ticket_enriched.created_at::timestamp, now()::timestamp ) /60) as numeric(28,6)), 4)
      end as unsolved_ticket_age_minutes,
  case when lower(ticket_enriched.status) not in ('solved','closed')
    then round(cast((date_diff('second', ticket_enriched.updated_at::timestamp, now()::timestamp ) /60) as numeric(28,6)), 4)
      end as unsolved_ticket_age_since_update_minutes,
  case when lower(ticket_enriched.status) in ('solved','closed') and ticket_comments.is_one_touch_resolution 
    then true
    else false
      end as is_one_touch_resolution,
  case when lower(ticket_enriched.status) in ('solved','closed') and ticket_comments.is_two_touch_resolution 
    then true
    else false 
      end as is_two_touch_resolution,
  case when lower(ticket_enriched.status) in ('solved','closed') and not ticket_comments.is_one_touch_resolution
      and not ticket_comments.is_two_touch_resolution 
    then true
    else false 
      end as is_multi_touch_resolution


from ticket_enriched

left join ticket_reply_times_calendar
  on ticket_enriched.ticket_id = ticket_reply_times_calendar.ticket_id 
  and ticket_enriched.source_relation = ticket_reply_times_calendar.source_relation

left join ticket_resolution_times_calendar
  on ticket_enriched.ticket_id = ticket_resolution_times_calendar.ticket_id 
  and ticket_enriched.source_relation = ticket_resolution_times_calendar.source_relation

left join ticket_work_time_calendar
  on ticket_enriched.ticket_id = ticket_work_time_calendar.ticket_id 
  and ticket_enriched.source_relation = ticket_work_time_calendar.source_relation

left join ticket_comments
  on ticket_enriched.ticket_id = ticket_comments.ticket_id 
  and ticket_enriched.source_relation = ticket_comments.source_relation



), business_hour_metrics as (

  select 
    ticket_enriched.source_relation,
    ticket_enriched.ticket_id,
    round(cast(ticket_resolution_time_business.first_resolution_business_minutes as numeric(28,6)), 4) as first_resolution_business_minutes,
    round(cast(ticket_resolution_time_business.full_resolution_business_minutes as numeric(28,6)), 4) as full_resolution_business_minutes,
    round(cast(ticket_first_reply_time_business.first_reply_time_business_minutes as numeric(28,6)), 4) as first_reply_time_business_minutes,
    round(cast(ticket_work_time_business.agent_wait_time_in_business_minutes as numeric(28,6)), 4) as agent_wait_time_in_business_minutes,
    round(cast(ticket_work_time_business.requester_wait_time_in_business_minutes as numeric(28,6)), 4) as requester_wait_time_in_business_minutes,
    round(cast(ticket_work_time_business.solve_time_in_business_minutes as numeric(28,6)), 4) as solve_time_in_business_minutes,
    round(cast(ticket_work_time_business.agent_work_time_in_business_minutes as numeric(28,6)), 4) as agent_work_time_in_business_minutes,
    round(cast(ticket_work_time_business.on_hold_time_in_business_minutes as numeric(28,6)), 4) as on_hold_time_in_business_minutes,
    round(cast(ticket_work_time_business.new_status_duration_in_business_minutes as numeric(28,6)), 4) as new_status_duration_in_business_minutes,
    round(cast(ticket_work_time_business.open_status_duration_in_business_minutes as numeric(28,6)), 4) as open_status_duration_in_business_minutes

  from ticket_enriched

  left join ticket_resolution_time_business
    on ticket_enriched.ticket_id = ticket_resolution_time_business.ticket_id 
    and ticket_enriched.source_relation = ticket_resolution_time_business.source_relation
  
  left join ticket_first_reply_time_business
    on ticket_enriched.ticket_id = ticket_first_reply_time_business.ticket_id 
    and ticket_enriched.source_relation = ticket_first_reply_time_business.source_relation
  
  left join ticket_work_time_business
    on ticket_enriched.ticket_id = ticket_work_time_business.ticket_id 
    and ticket_enriched.source_relation = ticket_work_time_business.source_relation

)

select
  calendar_hour_metrics.*,
  case when calendar_hour_metrics.status in ('solved', 'closed')
    then coalesce(business_hour_metrics.first_resolution_business_minutes,0)
    else null
      end as first_resolution_business_minutes,
  case when calendar_hour_metrics.status in ('solved', 'closed')
    then coalesce(business_hour_metrics.full_resolution_business_minutes,0)
    else null
      end as full_resolution_business_minutes,
  case when coalesce(calendar_hour_metrics.count_public_agent_comments, 0) = 0
    then null
    else coalesce(business_hour_metrics.first_reply_time_business_minutes,0)
      end as first_reply_time_business_minutes,
  coalesce(business_hour_metrics.agent_wait_time_in_business_minutes,0) as agent_wait_time_in_business_minutes,
  coalesce(business_hour_metrics.requester_wait_time_in_business_minutes,0) as requester_wait_time_in_business_minutes,
  coalesce(business_hour_metrics.solve_time_in_business_minutes,0) as solve_time_in_business_minutes,
  coalesce(business_hour_metrics.agent_work_time_in_business_minutes,0) as agent_work_time_in_business_minutes,
  coalesce(business_hour_metrics.on_hold_time_in_business_minutes,0) as on_hold_time_in_business_minutes,
  coalesce(business_hour_metrics.new_status_duration_in_business_minutes,0) as new_status_duration_in_business_minutes,
  coalesce(business_hour_metrics.open_status_duration_in_business_minutes,0) as open_status_duration_in_business_minutes

from calendar_hour_metrics

left join business_hour_metrics 
  on calendar_hour_metrics.ticket_id = business_hour_metrics.ticket_id
  and calendar_hour_metrics.source_relation = business_hour_metrics.source_relation
