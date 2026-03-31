with tickets as (
    select * from {{ ref('stg_support_tickets') }}
),

final as (
    select distinct
        category,
        case category
            when 'billing' then 'Finance'
            when 'technical' then 'Engineering'
            when 'account' then 'Customer Success'
            else 'General'
        end as department,
        case category
            when 'billing' then 1
            when 'account' then 2
            when 'technical' then 3
            else 4
        end as category_priority
    from tickets
)

select * from final
