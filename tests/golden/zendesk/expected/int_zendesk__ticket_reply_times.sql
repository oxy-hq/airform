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
), ticket_public_comments as (

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
