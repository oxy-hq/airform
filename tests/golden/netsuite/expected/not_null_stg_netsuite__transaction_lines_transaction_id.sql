select transaction_id
from "netsuite"."main_netsuite_source"."stg_netsuite__transaction_lines"
where transaction_id is null
