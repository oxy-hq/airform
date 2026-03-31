with a as (select * from {{ ref('stg_sessions_065') }}),
b as (select * from {{ ref('stg_sessions_072') }})
select a.payment_id, a.invoice_id, b.account_id
from a left join b on a.payment_id = b.order_id
