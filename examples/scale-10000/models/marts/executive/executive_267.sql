select user_id, count(*) as total
from {{ ref('stg_payments_067') }}
group by user_id
