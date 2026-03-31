select department_name, count(*) as total
from {{ ref('stg_subscriptions_057') }}
group by department_name
