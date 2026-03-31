with tickets as (
    select * from {{ ref('stg_support_tickets') }}
),

final as (
    select
        cast(created_at as date) as ticket_date,
        count(*) as tickets_created,
        sum(case when priority = 'critical' then 1 else 0 end) as critical_tickets,
        sum(case when priority = 'high' then 1 else 0 end) as high_tickets,
        sum(case when priority = 'medium' then 1 else 0 end) as medium_tickets,
        sum(case when priority = 'low' then 1 else 0 end) as low_tickets,
        count(distinct account_id) as distinct_accounts,
        count(distinct category) as distinct_categories
    from tickets
    group by cast(created_at as date)
)

select * from final
