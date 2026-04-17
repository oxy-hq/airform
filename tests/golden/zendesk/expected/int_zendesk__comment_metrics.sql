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
), ticket_comments as (

    select *
    from __dbt__cte__int_zendesk__comments_enriched
),

handoff_counts as (
    select
        source_relation,
        ticket_id,
        count(distinct case when commenter_role = 'internal_comment'
            then user_id
                end) as count_ticket_handoffs
    from ticket_comments

    group by 1, 2

),

comment_counts as (
    select
        source_relation,
        ticket_id,
        last_comment_added_at,
        sum(case when commenter_role = 'internal_comment' and is_public = true
            then 1
            else 0
                end) as count_public_agent_comments,
        sum(case when commenter_role = 'internal_comment'
            then 1
            else 0
                end) as count_agent_comments,
        sum(case when commenter_role = 'external_comment'
            then 1
            else 0
                end) as count_end_user_comments,
        sum(case when is_public = true
            then 1
            else 0
                end) as count_public_comments,
        sum(case when is_public = false
            then 1
            else 0
                end) as count_internal_comments,
        count(*) as total_comments,
        sum(case when commenter_role = 'internal_comment' and is_public = true and previous_commenter_role != 'first_comment'
            then 1
            else 0
                end) as count_agent_replies
    from ticket_comments
    where not is_chat_comment

    group by 1, 2, 3
),


chat_comment_counts as (
    select
        source_relation,
        ticket_id,
        last_comment_added_at,
        count(distinct case when commenter_role = 'internal_comment' and is_public = true
            then chat_id
            else null
                end) as count_public_agent_comments,
        count(distinct case when commenter_role = 'internal_comment'
            then chat_id
            else null
                end) as count_agent_comments,
        count(distinct case when commenter_role = 'external_comment'
            then chat_id
            else null
                end) as count_end_user_comments,
        count(distinct case when is_public = true
            then chat_id
            else null
                end) as count_public_comments,
        count(distinct case when is_public = false
            then chat_id
            else null
                end) as count_internal_comments,
        count(distinct chat_id) as total_comments,
        count(distinct case when commenter_role = 'internal_comment' and is_public = true and previous_commenter_role != 'first_comment'
            then chat_id
            else null
                end) as count_agent_replies
    from ticket_comments
    where is_chat_comment

    group by 1, 2, 3
),

comment_count_union as (
    select * from comment_counts

    union all

    select * from chat_comment_counts
),


consolidate_comment_counts as (
    select
        source_relation,
        ticket_id,
        max(last_comment_added_at) as last_comment_added_at,
        sum(count_public_agent_comments) as count_public_agent_comments,
        sum(count_agent_comments) as count_agent_comments,
        sum(count_end_user_comments) as count_end_user_comments,
        sum(count_public_comments) as count_public_comments,
        sum(count_internal_comments) as count_internal_comments,
        sum(total_comments) as total_comments,
        sum(count_agent_replies) as count_agent_replies
    from comment_count_union

    group by 1, 2
),

final as (
    select
        consolidate_comment_counts.*,
        handoff_counts.count_ticket_handoffs,
        consolidate_comment_counts.count_public_agent_comments = 1 as is_one_touch_resolution,
        consolidate_comment_counts.count_public_agent_comments = 2 as is_two_touch_resolution
    from consolidate_comment_counts
    left join handoff_counts
        on consolidate_comment_counts.source_relation = handoff_counts.source_relation
        and consolidate_comment_counts.ticket_id = handoff_counts.ticket_id
)

select * 
from final
