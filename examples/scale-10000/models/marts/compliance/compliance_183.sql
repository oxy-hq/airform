select account_id, count(*) as total
from {{ ref('stg_support_tickets_083') }}
group by account_id
