select invoice_id, count(*) as total
from {{ ref('stg_subscriptions_045') }}
group by invoice_id
