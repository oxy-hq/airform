select transaction_line_id
from "netsuite"."main_netsuite_source"."stg_netsuite2__transaction_lines"
where transaction_line_id is null
