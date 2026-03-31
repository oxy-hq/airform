with tickets as (
    select * from {{ ref('stg_support_tickets') }}
),

final as (
    select
        category,
        count(*) as total_tickets,
        sum(case when status = 'resolved' then 1 else 0 end) as resolved_count,
        sum(case when status = 'open' then 1 else 0 end) as open_count,
        sum(case when status = 'escalated' then 1 else 0 end) as escalated_count,
        avg(csat_score) as avg_csat,
        sum(case when priority in ('critical', 'high') then 1 else 0 end) as high_priority_count,
        case
            when count(*) > 0
            then cast(sum(case when status = 'resolved' then 1 else 0 end) as float)
                / cast(count(*) as float)
            else 0
        end as resolution_rate
    from tickets
    group by category
)

select * from final
