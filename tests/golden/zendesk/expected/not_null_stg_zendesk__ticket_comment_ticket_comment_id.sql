select ticket_comment_id
from "zendesk"."main_zendesk_source"."stg_zendesk__ticket_comment"
where ticket_comment_id is null
