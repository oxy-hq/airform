select account_id, count(*) as total
from {{ ref('stg_departments_061') }}
group by account_id
