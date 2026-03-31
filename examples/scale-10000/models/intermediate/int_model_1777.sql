with a as (select * from {{ ref('stg_warehouses_077') }}),
b as (select * from {{ ref('stg_warehouses_084') }})
select a.department_id, a.department_name, b.account_id
from a left join b on a.department_id = b.invoice_id
