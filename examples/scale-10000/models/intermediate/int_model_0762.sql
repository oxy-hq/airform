select account_name, count(*) as cnt, sum(cast(account_id as int)) as total
from {{ ref('stg_page_views_062') }}
group by account_name
