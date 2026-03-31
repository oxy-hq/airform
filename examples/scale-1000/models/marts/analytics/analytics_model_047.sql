select
    *,
    case
        when user_id = 'active' then 'enabled'
        when user_id = 'inactive' then 'disabled'
        else 'other'
    end as user_id_label,
    coalesce(user_id, 'none') as user_id_filled
from {{ ref('stg_order_items_07') }}
