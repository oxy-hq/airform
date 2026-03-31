select
    channel_id, channel_name, channel_type, is_active, created_at
from {{ ref('stg_feature_usage_05') }}
