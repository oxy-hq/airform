with tickets as (
    select * from {{ ref('stg_support_tickets') }}
),

priorities as (
    select * from {{ ref('stg_ticket_priorities') }}
),

final as (
    select
        tickets.ticket_id,
        tickets.account_id,
        tickets.agent_id,
        tickets.category,
        tickets.priority,
        priorities.priority_rank,
        tickets.status,
        tickets.created_at,
        tickets.resolved_at,
        tickets.first_response_at,
        case
            when tickets.status = 'resolved' then 'met'
            when tickets.status = 'escalated' then 'breached'
            when tickets.status = 'open' then 'pending'
            else 'unknown'
        end as sla_status
    from tickets
    left join priorities on tickets.ticket_id = priorities.ticket_id
)

select * from final
