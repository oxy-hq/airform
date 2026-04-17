select messaging_service_id
from "twilio"."main_twilio_source"."stg_twilio__messaging_service"
where messaging_service_id is null
