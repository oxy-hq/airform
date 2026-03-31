select account_id, count(*) as total
from {{ ref('stg_page_views_083') }}
group by account_id
