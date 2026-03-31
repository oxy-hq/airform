select
    *,
    case
        when channel_name = 'active' then 'enabled'
        when channel_name = 'inactive' then 'disabled'
        else 'other'
    end as channel_name_label,
    coalesce(channel_name, 'none') as channel_name_filled
from {{ ref('stg_feature_usage_05') }}
