select *, row_number() over (partition by order_id order by shipment_id) as rn
from {{ ref('stg_users_059') }}
