select
    *,
    case
        when status = 'active' then 'enabled'
        when status = 'inactive' then 'disabled'
        else 'other'
    end as status_label,
    coalesce(status, 'none') as status_filled
from {{ ref('stg_warehouses_03') }}
