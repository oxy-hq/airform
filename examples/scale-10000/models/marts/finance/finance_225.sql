select invoice_id, count(*) as total
from {{ ref('stg_events_025') }}
group by invoice_id
