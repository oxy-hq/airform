with tickets as (
    select * from {{ ref('stg_support_tickets') }}
),

final as (
    select
        agent_id,
        count(*) as total_tickets_handled,
        sum(case when status = 'resolved' then 1 else 0 end) as tickets_resolved,
        sum(case when status = 'escalated' then 1 else 0 end) as tickets_escalated,
        avg(csat_score) as avg_csat_score,
        sum(case when priority = 'critical' then 1 else 0 end) as critical_tickets
    from tickets
    group by agent_id
)

select * from final
