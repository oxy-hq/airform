with tickets as (
    select * from {{ ref('stg_support_tickets') }}
),

accounts as (
    select * from {{ ref('stg_accounts') }}
),

final as (
    select
        tickets.ticket_id,
        tickets.user_id,
        tickets.account_id,
        accounts.account_name,
        tickets.agent_id,
        tickets.category,
        tickets.priority,
        tickets.subject,
        tickets.created_at,
        tickets.first_response_at,
        case
            when tickets.priority = 'critical' then 'p0'
            when tickets.priority = 'high' then 'p1'
            else 'p2'
        end as escalation_level
    from tickets
    left join accounts on tickets.account_id = accounts.account_id
    where tickets.status = 'escalated'
        or tickets.priority in ('critical', 'high')
)

select * from final
