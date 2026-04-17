select updated_at
from "twilio"."main_twilio_source"."stg_twilio__account_history"
where updated_at is null
