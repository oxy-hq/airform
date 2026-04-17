select ticket_form_id
from "zendesk"."main_zendesk_source"."stg_zendesk__ticket_form_history"
where ticket_form_id is null
