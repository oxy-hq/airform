select invoice_id, count(*) as total
from {{ ref('stg_accounts_065') }}
group by invoice_id
