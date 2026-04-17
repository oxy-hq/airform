select fiscal_calendar_id
from "netsuite"."main_netsuite_source"."stg_netsuite__accounting_periods"
where fiscal_calendar_id is null
