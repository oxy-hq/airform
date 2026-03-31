select *,
    case when channel_name = 'active' then 'enabled' else 'other' end as channel_name_label
from {{ ref('stg_sessions_015') }}
