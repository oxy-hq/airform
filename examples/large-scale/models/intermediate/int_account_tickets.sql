with tickets as (
    select * from {{ ref('stg_support_tickets') }}
),

final as (
    select
        account_id,
        count(*) as total_tickets,
        sum(case when status = 'resolved' then 1 else 0 end) as resolved_tickets,
        sum(case when status = 'open' then 1 else 0 end) as open_tickets,
        sum(case when status = 'escalated' then 1 else 0 end) as escalated_tickets,
        sum(case when priority in ('high', 'critical') then 1 else 0 end) as high_priority_tickets,
        avg(csat_score) as avg_csat_score
    from tickets
    group by account_id
)

select * from final
