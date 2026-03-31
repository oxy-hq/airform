select user_id, count(*) as cnt, sum(cast(event_id as int)) as total
from {{ ref('stg_channels_086') }}
group by user_id
