select *,
    case when status = 'active' then 'enabled' else 'other' end as status_label
from {{ ref('stg_feature_usage_037') }}
