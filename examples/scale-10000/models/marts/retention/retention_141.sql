select account_id, count(*) as total
from {{ ref('stg_employees_041') }}
group by account_id
