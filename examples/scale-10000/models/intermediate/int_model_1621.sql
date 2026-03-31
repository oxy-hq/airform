with a as (select * from {{ ref('stg_departments_021') }}),
b as (select * from {{ ref('stg_departments_028') }})
select a.user_id, a.account_id, b.session_id
from a left join b on a.user_id = b.page_view_id
