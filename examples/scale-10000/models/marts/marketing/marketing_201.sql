select account_id, count(*) as total
from {{ ref('stg_support_tickets_001') }}
group by account_id
