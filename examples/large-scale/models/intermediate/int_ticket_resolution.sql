with tickets as (
    select * from {{ ref('stg_support_tickets') }}
),

final as (
    select
        ticket_id,
        user_id,
        account_id,
        agent_id,
        category,
        priority,
        status,
        created_at,
        resolved_at,
        first_response_at,
        csat_score,
        case
            when status = 'resolved' then 1
            else 0
        end as is_resolved,
        case
            when priority in ('critical', 'high') then 1
            else 0
        end as is_high_priority
    from tickets
)

select * from final
