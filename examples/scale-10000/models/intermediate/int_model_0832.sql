select *,
    case when status = 'active' then 1 when status = 'inactive' then 0 else -1 end as status_flag,
    coalesce(status, 'unknown') as status_clean
from {{ ref('stg_support_tickets_032') }}
