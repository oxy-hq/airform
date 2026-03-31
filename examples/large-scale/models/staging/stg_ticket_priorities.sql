with source as (
    select * from {{ source('raw', 'raw_support_tickets') }}
),

final as (
    select
        id as ticket_id,
        priority,
        case priority
            when 'critical' then 4
            when 'high' then 3
            when 'medium' then 2
            when 'low' then 1
            else 0
        end as priority_rank,
        category,
        status,
        created_at
    from source
)

select * from final
