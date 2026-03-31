with agent_metrics as (
    select * from {{ ref('int_ticket_agent_metrics') }}
),

final as (
    select
        agent_id,
        total_tickets_handled,
        tickets_resolved,
        tickets_escalated,
        avg_csat_score,
        critical_tickets,
        case
            when total_tickets_handled > 0
            then cast(tickets_resolved as float) / cast(total_tickets_handled as float)
            else 0
        end as resolution_rate,
        case
            when avg_csat_score >= 4.5 then 'excellent'
            when avg_csat_score >= 3.5 then 'good'
            when avg_csat_score >= 2.5 then 'average'
            else 'needs_improvement'
        end as performance_tier
    from agent_metrics
)

select * from final
