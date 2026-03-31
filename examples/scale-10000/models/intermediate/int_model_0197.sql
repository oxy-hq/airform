with a as (select * from {{ ref('stg_accounts_097') }}),
b as (select * from {{ ref('stg_subscriptions_004') }})
select a.department_id, a.department_name, b.account_id
from a left join b on a.department_id = b.invoice_id
