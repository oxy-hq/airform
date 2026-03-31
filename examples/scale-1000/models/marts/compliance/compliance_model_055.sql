select
    channel_id, channel_name, channel_type, is_active, created_at
from {{ ref('stg_compliance_records_05') }}
