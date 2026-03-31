with source as (
    select * from {{ source('raw', 'raw_sessions') }}
),

final as (
    select
        id as session_id,
        user_id,
        started_at,
        ended_at,
        case
            when ended_at is not null then 'completed'
            else 'active'
        end as session_status,
        device_type,
        browser
    from source
)

select * from final
