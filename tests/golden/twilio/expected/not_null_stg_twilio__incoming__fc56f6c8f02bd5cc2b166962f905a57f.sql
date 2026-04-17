select incoming_phone_number_id
from "twilio"."main_twilio_source"."stg_twilio__incoming_phone_number"
where incoming_phone_number_id is null
