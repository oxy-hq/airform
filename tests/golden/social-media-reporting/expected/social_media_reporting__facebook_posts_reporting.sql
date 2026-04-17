with report as (

    select *
    from facebook_pages__posts_report
    where is_most_recent_record = True

), fields as (

    select
        created_timestamp,
        cast(post_id as TEXT) as post_id,
        cast(post_message as TEXT) as post_message,
        cast(post_url as TEXT) as post_url,
        cast(page_id as TEXT) as page_id,
        cast(page_name as TEXT) as page_name,
        source_relation,
        'facebook' as platform,
        coalesce(sum(clicks),0) as clicks,
        coalesce(sum(impressions),0) as impressions, -- Deprecated as of November, 2025. Will be removed in future release.
        coalesce(sum(likes),0) as likes
    from report
    group by 1,2,3,4,5,6,7,8

)

select *
from fields
