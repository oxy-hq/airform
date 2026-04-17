select invoice_item_id
from "sage_intacct"."main_sage_intacct_staging"."stg_sage_intacct__ar_invoice_item"
where invoice_item_id is null
