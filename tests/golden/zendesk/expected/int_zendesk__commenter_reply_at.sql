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
