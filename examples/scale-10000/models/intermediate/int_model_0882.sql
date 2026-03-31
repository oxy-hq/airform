select account_name, count(*) as cnt, sum(cast(account_id as int)) as total
from {{ ref('stg_support_tickets_082') }}
group by account_name
