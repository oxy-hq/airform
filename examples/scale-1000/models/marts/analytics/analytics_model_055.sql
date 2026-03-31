select
    channel_id, channel_name, channel_type, is_active, created_at
from {{ ref('stg_campaigns_05') }}
