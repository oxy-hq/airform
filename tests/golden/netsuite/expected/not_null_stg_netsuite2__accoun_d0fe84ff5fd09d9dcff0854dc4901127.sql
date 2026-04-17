select _fivetran_id
from "netsuite"."main_netsuite_source"."stg_netsuite2__accounting_book_subsidiaries"
where _fivetran_id is null
