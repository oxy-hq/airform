select account_id
from "twilio"."main_twilio_source"."stg_twilio__message"
where account_id is null
