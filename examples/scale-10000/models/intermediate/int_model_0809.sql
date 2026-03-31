with a as (select * from {{ ref('stg_support_tickets_009') }}),
b as (select * from {{ ref('stg_support_tickets_016') }})
select a.support_ticket_id, a.user_id, b.department_id
from a left join b on a.support_ticket_id = b.employee_id
