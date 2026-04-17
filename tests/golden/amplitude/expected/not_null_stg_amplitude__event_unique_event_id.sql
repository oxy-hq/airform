select unique_event_id
from "amplitude"."main__source_amplitude"."stg_amplitude__event"
where unique_event_id is null
