select user_id, count(*) as total
from {{ ref('stg_payments_049') }}
group by user_id
