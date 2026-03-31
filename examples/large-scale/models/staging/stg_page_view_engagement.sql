with source as (
    select * from {{ source('raw', 'raw_page_views') }}
),

final as (
    select
        id as page_view_id,
        user_id,
        session_id,
        page_url,
        time_on_page_seconds,
        case
            when time_on_page_seconds >= 300 then 'high'
            when time_on_page_seconds >= 60 then 'medium'
            else 'low'
        end as engagement_level,
        viewed_at
    from source
)

select * from final
