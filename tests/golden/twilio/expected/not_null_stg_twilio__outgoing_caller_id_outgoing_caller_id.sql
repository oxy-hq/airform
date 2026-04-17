select outgoing_caller_id
from "twilio"."main_twilio_source"."stg_twilio__outgoing_caller_id"
where outgoing_caller_id is null
