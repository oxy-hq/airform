select account_id, count(*) as total
from {{ ref('stg_page_views_081') }}
group by account_id
