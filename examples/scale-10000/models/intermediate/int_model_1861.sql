with a as (select * from {{ ref('stg_shipments_061') }}),
b as (select * from {{ ref('stg_shipments_068') }})
select a.user_id, a.account_id, b.session_id
from a left join b on a.user_id = b.page_view_id
