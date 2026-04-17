select end_date
from "twilio"."main_twilio_source"."stg_twilio__usage_record"
where end_date is null
