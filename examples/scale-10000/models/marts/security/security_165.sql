select invoice_id, count(*) as total
from {{ ref('stg_warehouses_065') }}
group by invoice_id
