select invoice_id, count(*) as total
from {{ ref('stg_events_085') }}
group by invoice_id
