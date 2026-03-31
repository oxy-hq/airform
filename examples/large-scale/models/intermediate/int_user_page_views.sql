with page_views as (
    select * from {{ ref('stg_page_views') }}
),

final as (
    select
        user_id,
        count(*) as total_page_views,
        count(distinct page_url) as distinct_pages,
        sum(time_on_page_seconds) as total_time_on_pages,
        avg(time_on_page_seconds) as avg_time_per_page,
        min(viewed_at) as first_page_view_at,
        max(viewed_at) as last_page_view_at
    from page_views
    group by user_id
)

select * from final
