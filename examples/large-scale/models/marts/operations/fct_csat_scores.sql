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
        csat_score,
        case
            when csat_score >= 4 then 'satisfied'
            when csat_score >= 3 then 'neutral'
            when csat_score >= 1 then 'dissatisfied'
            else 'no_response'
        end as satisfaction_level,
        created_at,
        resolved_at
    from tickets
    where csat_score is not null
)

select * from final
