select _fivetran_id
from "netsuite"."main_netsuite_source"."stg_netsuite2__accounting_period_fiscal_cal"
where _fivetran_id is null
