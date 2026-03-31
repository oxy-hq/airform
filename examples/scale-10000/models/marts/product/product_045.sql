select invoice_id, count(*) as total
from {{ ref('stg_feature_usage_045') }}
group by invoice_id
