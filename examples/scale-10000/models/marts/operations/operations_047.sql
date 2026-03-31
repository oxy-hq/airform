select *,
    case when user_id = 'active' then 'enabled' else 'other' end as user_id_label
from {{ ref('stg_order_items_047') }}
