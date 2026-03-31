select account_id, count(*) as total
from {{ ref('stg_invoices_063') }}
group by account_id
