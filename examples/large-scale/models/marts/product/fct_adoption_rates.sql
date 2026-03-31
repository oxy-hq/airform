with adoption as (
    select * from {{ ref('int_feature_adoption') }}
),

final as (
    select
        feature_name,
        users_using,
        total_users,
        adoption_rate,
        total_usage,
        avg_duration,
        case
            when adoption_rate >= 0.5 then 'high'
            when adoption_rate >= 0.2 then 'medium'
            else 'low'
        end as adoption_tier
    from adoption
)

select * from final
