with a as (select * from {{ ref('stg_order_items_093') }}),
b as (select * from {{ ref('stg_order_items_100') }})
select a.order_item_id, a.order_id, b.account_id
from a left join b on a.order_item_id = b.compliance_record_id
