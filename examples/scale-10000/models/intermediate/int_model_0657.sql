with a as (select * from {{ ref('stg_sessions_057') }}),
b as (select * from {{ ref('stg_sessions_064') }})
select a.department_id, a.department_name, b.account_id
from a left join b on a.department_id = b.invoice_id
