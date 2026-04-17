select transaction_id
from "netsuite"."main_netsuite_source"."stg_netsuite2__transaction_accounting_lines"
where transaction_id is null
