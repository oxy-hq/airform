select user_id, count(*) as total
from {{ ref('stg_payments_047') }}
group by user_id
