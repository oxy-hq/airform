with a as (select * from {{ ref('stg_feature_usage_085') }}),
b as (select * from {{ ref('stg_feature_usage_092') }})
select a.payment_id, a.invoice_id, b.account_id
from a left join b on a.payment_id = b.order_id
