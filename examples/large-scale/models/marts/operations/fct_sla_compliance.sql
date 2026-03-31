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
        tickets.priority,
        priorities.priority_rank,
        tickets.status,
        tickets.created_at,
        tickets.first_response_at,
        tickets.resolved_at,
        case
            when tickets.first_response_at is not null then 1
            else 0
        end as has_first_response,
        case
            when tickets.status = 'resolved' then 1
            when tickets.status = 'escalated' then 0
            else null
        end as sla_met
    from tickets
    left join priorities on tickets.ticket_id = priorities.ticket_id
)

select * from final
