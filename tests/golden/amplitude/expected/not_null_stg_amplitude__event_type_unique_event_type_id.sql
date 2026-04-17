select unique_event_type_id
from "amplitude"."main__source_amplitude"."stg_amplitude__event_type"
where unique_event_type_id is null
