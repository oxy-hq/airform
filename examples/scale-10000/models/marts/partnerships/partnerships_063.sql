select account_id, count(*) as total
from {{ ref('stg_support_tickets_063') }}
group by account_id
