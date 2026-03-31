with a as (select * from {{ ref('stg_support_tickets_041') }}),
b as (select * from {{ ref('stg_support_tickets_048') }})
select a.user_id, a.account_id, b.session_id
from a left join b on a.user_id = b.page_view_id
