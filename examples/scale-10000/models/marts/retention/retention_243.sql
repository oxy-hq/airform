select account_id, count(*) as total
from {{ ref('stg_departments_043') }}
group by account_id
