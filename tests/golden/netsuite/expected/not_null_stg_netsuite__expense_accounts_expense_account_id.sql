select expense_account_id
from "netsuite"."main_netsuite_source"."stg_netsuite__expense_accounts"
where expense_account_id is null
