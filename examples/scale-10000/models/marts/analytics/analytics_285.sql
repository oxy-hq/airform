select invoice_id, count(*) as total
from {{ ref('stg_sessions_085') }}
group by invoice_id
