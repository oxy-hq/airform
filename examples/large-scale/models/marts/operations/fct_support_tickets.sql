with tickets as (
    select * from {{ ref('stg_support_tickets') }}
),

resolution as (
    select * from {{ ref('int_ticket_resolution') }}
),

users as (
    select * from {{ ref('stg_users') }}
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
        tickets.status,
        tickets.created_at,
        tickets.resolved_at,
        tickets.first_response_at,
        tickets.csat_score,
        resolution.is_resolved,
        resolution.is_high_priority
    from tickets
    left join resolution on tickets.ticket_id = resolution.ticket_id
    left join users on tickets.user_id = users.user_id
    left join accounts on tickets.account_id = accounts.account_id
)

select * from final
