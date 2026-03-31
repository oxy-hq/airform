with page_views as (
    select * from {{ ref('stg_page_views') }}
),

final as (
    select
        session_id,
        count(*) as page_view_count,
        count(distinct page_url) as distinct_pages,
        sum(time_on_page_seconds) as total_time_seconds,
        min(viewed_at) as session_first_page_view,
        max(viewed_at) as session_last_page_view
    from page_views
    group by session_id
)

select * from final
