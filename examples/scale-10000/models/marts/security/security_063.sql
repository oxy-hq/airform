select account_id, count(*) as total
from {{ ref('stg_departments_063') }}
group by account_id
