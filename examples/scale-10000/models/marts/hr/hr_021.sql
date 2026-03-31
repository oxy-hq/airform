select account_id, count(*) as total
from {{ ref('stg_employees_021') }}
group by account_id
