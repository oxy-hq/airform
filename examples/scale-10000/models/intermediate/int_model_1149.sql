with a as (select * from {{ ref('stg_orders_049') }}),
b as (select * from {{ ref('stg_orders_056') }})
select a.support_ticket_id, a.user_id, b.department_id
from a left join b on a.support_ticket_id = b.employee_id
