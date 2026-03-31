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
        created_at,
        first_response_at,
        case
            when first_response_at is not null then 1
            else 0
        end as has_response,
        case
            when priority = 'critical' then 15
            when priority = 'high' then 60
            when priority = 'medium' then 240
            else 480
        end as sla_target_minutes
    from tickets
)

select * from final
