select *, row_number() over (partition by user_id order by session_id) as rn
from {{ ref('stg_payments_087') }}
