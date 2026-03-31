select invoice_id, count(*) as total
from {{ ref('stg_users_005') }}
group by invoice_id
