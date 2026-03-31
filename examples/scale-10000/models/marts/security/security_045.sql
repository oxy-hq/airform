select invoice_id, count(*) as total
from {{ ref('stg_departments_045') }}
group by invoice_id
