select *,
    case when status = 'active' then 'enabled' else 'other' end as status_label
from {{ ref('stg_support_tickets_073') }}
