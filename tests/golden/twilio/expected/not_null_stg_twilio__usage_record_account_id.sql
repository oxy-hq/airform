select account_id
from "twilio"."main_twilio_source"."stg_twilio__usage_record"
where account_id is null
