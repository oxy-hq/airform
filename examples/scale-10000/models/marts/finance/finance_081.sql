select account_id, count(*) as total
from {{ ref('stg_invoices_081') }}
group by account_id
