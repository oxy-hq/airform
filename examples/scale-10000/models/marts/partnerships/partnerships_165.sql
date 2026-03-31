select invoice_id, count(*) as total
from {{ ref('stg_feature_usage_065') }}
group by invoice_id
