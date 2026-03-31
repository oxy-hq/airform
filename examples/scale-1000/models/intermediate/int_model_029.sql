with a as (
    select * from {{ ref('stg_subscriptions_09') }}
),

b as (
    select * from {{ ref('stg_invoices_06') }}
),

final as (
    select
        a.support_ticket_id,
        a.user_id,
        a.account_id,
        b.employee_id,
        b.department_id,
        b.first_name
    from a
    left join b on a.support_ticket_id = b.employee_id
)

select * from final
