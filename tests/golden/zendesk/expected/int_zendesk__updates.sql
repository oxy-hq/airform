with ticket_history as (
    select *
    from "zendesk"."main_zendesk_source"."stg_zendesk__ticket_field_history"

), ticket_comment as (
    select *
    from "zendesk"."main_zendesk_source"."stg_zendesk__ticket_comment"

), tickets as (
    select *
    from "zendesk"."main_zendesk_source"."stg_zendesk__ticket"



), updates_union as (
    select 
        source_relation,
        ticket_id,
        field_name,
        value,
        cast(null as TEXT) as chat_id,
        cast(null as boolean) as is_chat_comment,
        cast(null as boolean) as is_public,
        user_id,
        valid_starting_at,
        valid_ending_at
    from ticket_history

    union all

    select
        source_relation,
        ticket_id,
        cast('comment' as TEXT) as field_name,
        body as value,
        cast(null as TEXT) as chat_id,
        false as is_chat_comment,
        is_public,
        user_id,
        created_at as valid_starting_at,
        lead(created_at) over (partition by ticket_id  order by created_at) as valid_ending_at
    from ticket_comment



), final as (
    select
        updates_union.source_relation,
        updates_union.ticket_id,
        updates_union.field_name,
        updates_union.value,
        updates_union.chat_id,
        updates_union.is_chat_comment,
        updates_union.is_public,
        updates_union.user_id,
        updates_union.valid_starting_at,
        updates_union.valid_ending_at,
        tickets.created_at as ticket_created_date
    from updates_union

    left join tickets
        on tickets.ticket_id = updates_union.ticket_id
        and tickets.source_relation = updates_union.source_relation
)

select *
from final
