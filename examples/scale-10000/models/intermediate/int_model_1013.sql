with a as (select * from {{ ref('stg_products_013') }}),
b as (select * from {{ ref('stg_products_020') }})
select a.order_item_id, a.order_id, b.account_id
from a left join b on a.order_item_id = b.compliance_record_id
