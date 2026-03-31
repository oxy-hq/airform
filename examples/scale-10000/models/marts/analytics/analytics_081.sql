select account_id, count(*) as total
from {{ ref('stg_payments_081') }}
group by account_id
