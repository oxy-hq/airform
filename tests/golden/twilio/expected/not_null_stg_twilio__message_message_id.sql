select message_id
from "twilio"."main_twilio_source"."stg_twilio__message"
where message_id is null
