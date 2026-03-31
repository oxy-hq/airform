select account_id, count(*) as total
from {{ ref('stg_employees_081') }}
group by account_id
