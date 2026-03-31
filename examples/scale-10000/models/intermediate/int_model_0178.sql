select warehouse_name, count(*) as cnt, sum(cast(warehouse_id as int)) as total
from {{ ref('stg_accounts_078') }}
group by warehouse_name
